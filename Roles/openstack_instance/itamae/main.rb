require './Modules/defaults'
require './Modules/blockinfile'
require './Modules/openstack_credential'
node.reverse_merge!(defaults_load(__FILE__))

tmp_dir = node['openstack_instance']['tmp_dir']
instances = node['openstack_instance']['instances']
credential_str = openstack_credential(node['openstack_instance']['credential'])

# create instances
instances.each do |instance|

  # check prameter "state"
  if instance['state'] != "present" && instance['state'] != "absent"
    fail 'parameter "state" should be "present" or "absent" '
  end

  if instance['state'] == "present"

    user_data_opt = ""
    if instance['user_data'] != nil
      # create tmp dir and send user data
      check_cmd = "#{ credential_str } openstack server show #{ instance['name'] }"
      create_instance = run_command(check_cmd, error: false).exit_status
      if create_instance != 0
        directory tmp_dir do
          action :create
        end
        remote_file "#{ tmp_dir }/#{ instance['user_data'] }" do
          action :create
          source "user_files/#{ instance['user_data'] }"
        end
      end
      # create option string of user data
      user_data_opt = "--user-data #{ tmp_dir }/#{ instance['user_data'] }"
    end

    # create security group string
    sec_grps_opt = ""
    instance['security_groups'].each do |sec_grp|
      sec_grps_opt += "--security-group #{ sec_grp } "
    end

    # create option string of nics
    nics_opt = ""
    instance['nics'].each do |nic|
      nics_opt += "--nic net-id=`#{ credential_str } openstack network list | grep #{ nic['network'] } | awk '{ print $2 }' `"
      if nic['ip'] != nil
        nics_opt += ",v4-fixed-ip=#{ nic['ip'] } "
      else
        nics_opt += " "
      end
    end
  
    execute <<-"EOS" do
      #{ credential_str } \\
      openstack server create \\
      --image #{ instance['image'] } \\
      --flavor #{ instance['flavor']} \\
      #{ sec_grps_opt } \\
      --key-name #{ instance['key_pair'] } \\
      #{ nics_opt } \\
      #{ user_data_opt } \\
      #{ instance['name'] }
    EOS
      not_if <<-"EOS"
        #{ credential_str } openstack server show #{ instance['name'] }
      EOS
    end

    if instance['floating_ip'] != nil
      execute <<-"EOS" do
        #{ credential_str } \\
        openstack ip floating add #{ instance['floating_ip'] } #{ instance['name'] }
      EOS
        not_if <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
            grep addresses | grep #{ instance['floating_ip'] }
        EOS
      end
    else
      find_floating_ip_cmd = <<-"EOS"
        #{ credential_str } \\
        openstack server show #{ instance['name'] } | grep addresses | \\
          awk -F\\| '{ print $3 }' | \\
          sed s/,//g | \\
          sed s/\\;//g | \\
          sed s/[^\\ ]*=[^\\ ]*//g | \\
          sed s/\\ //g
      EOS
      execute <<-"EOS" do     
        #{ credential_str } \\
        openstack ip floating remove \\
          `#{ find_floating_ip_cmd.chomp }` \\
          #{ instance['name']}
      EOS
        not_if <<-"EOS"
          test -z `#{ find_floating_ip_cmd }`
        EOS
      end
    end
  end

  if instance['state'] == "absent"
    execute <<-"EOS" do
      #{ credential_str } \\
      openstack server delete \\
      #{ instance['name'] }
    EOS
      only_if <<-"EOS"
        #{ credential_str } openstack server show #{ instance['name'] }
      EOS
    end
  end
end

# remove tmp dir
directory tmp_dir do
  action :delete
end

