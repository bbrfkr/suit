require './Modules/spec_helper_serverspec'
require './Modules/defaults'
property.reverse_merge!(defaults_load(__FILE__))

credential = property['openstack_instance']['credential']
instances = property['openstack_instance']['instances']

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

describe ("openstack_instances") do
  instances.each do |instance|
    describe ("instance \"#{ instance['name'] }\"") do
      describe ("check instance is active") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep status
        EOS
        describe command(cmd) do
          its(:stdout) { should match /ACTIVE/ }
        end
      end

      describe ("check instance name is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep name
        EOS
        describe command(cmd) do
          its(:stdout) { should match /#{ instance['name'] }/ }
        end
      end

      describe ("check image used by instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep image
        EOS
        describe command(cmd) do
          its(:stdout) { should match /#{ instance['image'] }/ }
        end
      end

      describe ("check falvor used by instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep flavor
        EOS
        describe command(cmd) do
          its(:stdout) { should match /#{ instance['flavor'] }/ }
        end
      end

      describe ("check security groups set to instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep security_groups
        EOS
        describe command(cmd) do
          instance['security_groups'].each do |sec_grp|
            its(:stdout) { should match /#{ sec_grp }/ }
          end
        end
      end

      describe ("check key pair set to instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep key_name
        EOS
        describe command(cmd) do
          its(:stdout) { should match /#{ instance['key_pair'] }/ }
        end
      end

      describe ("check network used by instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep addresses
        EOS
        describe command(cmd) do
          its(:stdout) { should match /#{ instance['network'] }=/ }
        end
      end
    end
  end
end
