require './Modules/defaults'
require './Modules/blockinfile'
node.reverse_merge!(defaults_load(__FILE__))

credential = node['openstack_instance']['credential']
instances = node['openstack_instance']['instances']

# create credential string
credential_str = ""
credential_str += "OS_PROJECT_DOMAIN_NAME=" + credential['project_domain'] + " "
credential_str += "OS_USER_DOMAIN_NAME=" + credential['user_domain'] + " "
credential_str += "OS_PROJECT_NAME=" + credential['project'] + " "
credential_str += "OS_USERNAME=" + credential['user'] + " "
credential_str += "OS_PASSWORD=" + credential['password'] + " "
credential_str += "OS_AUTH_URL=" + credential['auth_url'] + " "
credential_str += "OS_IDENTITY_API_VERSION=" + credential['identity_api_version'].to_s + " "
credential_str += "OS_IMAGE_API_VERSION=" + credential['image_api_version'].to_s + " "

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

