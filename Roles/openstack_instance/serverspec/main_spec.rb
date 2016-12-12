require './Modules/spec_helper_serverspec'
require './Modules/defaults'
require './Modules/openstack_credential'
property.reverse_merge!(defaults_load(__FILE__))

instances = property['openstack_instance']['instances']
credential_str = openstack_credential(property['openstack_instance']['credential'])

describe ("openstack_instances") do
  instances.each do |instance|
    # check prameter "state"
    if instance['state'] != "present" && instance['state'] != "absent"
      fail 'parameter "state" should be "present" or "absent" '
    end

    describe ("instance \"#{ instance['name'] }\"") do
      if instance['state'] == "present"
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
  
        describe ("check network and ip used by instance are appropriate") do
          cmd = <<-"EOS"
            #{ credential_str } \\
            openstack server show #{ instance['name'] } | \\
            grep addresses | \\
            awk -F\\| '{ print $3 }'
          EOS
          describe command(cmd) do
            instance['nics'].each do |nic|
              if nic['ip'] != nil
                its(:stdout) { should match /\s+#{ nic['network'] }=#{ nic['ip'] }[\s,;]/ }
              else
                its(:stdout) { should match /\s+#{ nic['network'] }=/ }
              end
            end
          end
        end

        if instance['floating_ip'] != nil
          describe ("check floating ip is added to instance") do
            cmd = <<-"EOS"
              #{ credential_str } \\
              openstack server show #{ instance['name'] } | \\
                grep addresses | grep #{ instance['floating_ip'] }
            EOS
            describe command(cmd) do
              its(:exit_status) { should eq 0 }
            end
          end
        else
          describe ("check floating ip is removed from instance") do
            cmd = <<-"EOS"
              test -z \\
              `#{ credential_str } \\
              openstack server show #{ instance['name'] } | grep addresses | \\
                awk -F\\| '{ print $3 }' | \\
                sed s/,//g | \\
                sed s/\\;//g | \\
                sed s/[^\\ ]*=[^\\ ]*//g | \\
                sed s/\\ //g`
            EOS
            describe command(cmd) do
              its(:exit_status) { should eq 0 }
            end
          end
        end
      end

      if instance['state'] == "absent"
        describe ("check instance doesn't exist") do
          cmd = <<-"EOS"
            #{ credential_str } \\
            openstack server show #{ instance['name'] }
          EOS
          describe command(cmd) do
            its(:exit_status) { should_not eq 0 }
          end
        end
      end
    end
  end
end
