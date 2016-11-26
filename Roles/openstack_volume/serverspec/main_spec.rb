require './Modules/spec_helper_serverspec'
require './Modules/defaults'
require './Modules/openstack_credential'
property.reverse_merge!(defaults_load(__FILE__))

volumes = property['openstack_volume']['volumes']
credential_str = openstack_credential(property['openstack_volume']['credential'])

describe ("openstack_volume") do
  volumes.each do |volume|
    describe ("volume \"#{ volume['name'] }\"") do
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
    end
  end
end
