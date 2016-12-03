require './Modules/defaults'
require './Modules/blockinfile'
require './Modules/openstack_credential'
node.reverse_merge!(defaults_load(__FILE__))

instances = node['openstack_instance']['instances']
credential_str = openstack_credential(node['openstack_instance']['credential'])

# create instances
instances.each do |instance|

  # check prameter "state"
  if instance['state'] != "present" && instance['state'] != "absent"
    fail 'parameter "state" should be "present" or "absent" '
  end

  if instance['state'] == "present"
    sec_grps_opt = ""
    instance['security_groups'].each do |sec_grp|
      sec_grps_opt += "--security-group #{ sec_grp } "
    end
  
    execute <<-"EOS" do
      #{ credential_str } \\
      openstack server create \\
      --image #{ instance['image'] } \\
      --flavor #{ instance['flavor']} \\
      #{ sec_grps_opt } \\
      --key-name #{ instance['key_pair'] } \\
      --nic net-id=`#{ credential_str } openstack network list | grep #{ instance['network'] } | awk '{ print $2 }' ` \\
      #{ instance['name'] }
    EOS
      not_if <<-"EOS"
        #{ credential_str } openstack server show #{ instance['name'] }
      EOS
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

