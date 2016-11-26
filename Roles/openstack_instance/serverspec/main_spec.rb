require './Modules/spec_helper_serverspec'
require './Modules/defaults'
require './Modules/openstack_credential'
property.reverse_merge!(defaults_load(__FILE__))

instances = property['openstack_instance']['instances']
credential_str = openstack_credential(property['openstack_instance']['credential'])

describe ("openstack_instances") do
  instances.each do |instance|
    describe ("instance \"#{ instance['name'] }\"") do
      describe ("check instance is active") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep status | \\
          awk '{ print $4 }'
        EOS
        describe command(cmd) do
          its(:stdout) { should match /^ACTIVE$/ }
        end
      end

      describe ("check instance name is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep name | \\
          awk '{ print $4 }'
        EOS
        describe command(cmd) do
          its(:stdout) { should match /^#{ instance['name'] }$/ }
        end
      end

      describe ("check image used by instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep image | \\
          awk '{ print $4 }'
        EOS
        describe command(cmd) do
          its(:stdout) { should match /^#{ instance['image'] }$/ }
        end
      end

      describe ("check falvor used by instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep flavor | \\
          awk '{ print $4 }'
        EOS
        describe command(cmd) do
          its(:stdout) { should match /^#{ instance['flavor'] }$/ }
        end
      end

      describe ("check security groups set to instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep security_groups | \\
          awk -F\\| '{ print $3 }'
        EOS
        describe command(cmd) do
          instance['security_groups'].each do |sec_grp|
            its(:stdout) { should match /u'#{ sec_grp }'/ }
          end
        end
      end

      describe ("check key pair set to instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep key_name | \\
          awk '{ print $4 }'
        EOS
        describe command(cmd) do
          its(:stdout) { should match /^#{ instance['key_pair'] }$/ }
        end
      end

      describe ("check network used by instance is appropriate") do
        cmd = <<-"EOS"
          #{ credential_str } \\
          openstack server show #{ instance['name'] } | \\
          grep addresses | \\
          awk '{ print $4 }'
        EOS
        describe command(cmd) do
          its(:stdout) { should match /^#{ instance['network'] }=/ }
        end
      end
    end
  end
end
