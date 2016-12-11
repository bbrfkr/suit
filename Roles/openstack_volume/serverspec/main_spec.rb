require './Modules/spec_helper_serverspec'
require './Modules/defaults'
require './Modules/openstack_credential'
property.reverse_merge!(defaults_load(__FILE__))

volumes = property['openstack_volume']['volumes']
credential_str = openstack_credential(property['openstack_volume']['credential'])

describe ("openstack_volume") do
  volumes.each do |volume|
    # check prameter "state"
    if volume['state'] != "present" && volume['state'] != "absent"
      fail 'parameter "state" should be "present" or "absent" '
    end

    describe ("volume \"#{ volume['name'] }\"") do
      if volume['state'] == "present"
        describe ("check volume is active") do
          cmd = <<-"EOS"
            #{ credential_str } \\
            openstack volume show #{ volume['name'] } | \\
            grep status | \\
            awk '{ print $4 }'
          EOS
          describe command(cmd) do
            its(:stdout) { should match(/^available$/).or match(/^in-use$/) }
          end
        end
  
        describe ("check volume name is appropriate") do
          cmd = <<-"EOS"
            #{ credential_str } \\
            openstack volume show #{ volume['name'] } | \\
            grep name | \\
            awk '{ print $4 }'
          EOS
          describe command(cmd) do
            its(:stdout) { should match /^#{ volume['name'] }$/ }
          end
        end
  
        describe ("check volume size is appropriate") do
          cmd = <<-"EOS"
            #{ credential_str } \\
            openstack volume show #{ volume['name'] } | \\
            grep size | \\
            awk '{ print $4 }'
          EOS
          describe command(cmd) do
            its(:stdout) { should match /^#{ volume['size'] }$/ }
          end
        end

        if volume['attached_instance'] != nil
          describe ("check volume is attached to appropriate instance") do
            cmd = <<-"EOS"
              #{ credential_str } \\
              openstack volume list | \\
              grep #{ volume['name'] } | \\
              awk '{ print $12 }'
            EOS
            describe command(cmd) do
              its(:stdout) { should match /^#{ volume['attached_instance'] }$/ }
            end
          end
        else
          describe ("check volume is not attached to any instance") do
            cmd = <<-"EOS"
              #{ credential_str } \\
              openstack volume list | \\
              grep #{ volume['name'] } | \\
              grep available
            EOS
            describe command(cmd) do
              its(:exit_status) { should eq 0 }
            end
          end
        end
      end

      if volume['state'] == "absent"
        describe ("check volume doesn't exist") do
          cmd = <<-"EOS"
            #{ credential_str } \\
            openstack volume show #{ volume['name'] }
          EOS
          describe command(cmd) do
            its(:exit_status) { should_not eq 0 }
          end
        end
      end
    end
  end
end
