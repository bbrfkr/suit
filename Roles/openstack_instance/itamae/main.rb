require './Modules/defaults'
require './Modules/blockinfile'
require './Modules/openstack_credential'
node.reverse_merge!(defaults_load(__FILE__))

instances = node['openstack_instance']['instances']
credential_str = openstack_credential(node['openstack_instance']['credential'])

# create instances
instances.each do |instance|
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

