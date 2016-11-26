require './Modules/defaults'
require './Modules/blockinfile'
require './Modules/openstack_credential'
node.reverse_merge!(defaults_load(__FILE__))

volumes = node['openstack_volume']['volumes']
credential_str = openstack_credential(node['openstack_volume']['credential'])

# create volumes
volumes.each do |volume|
  execute <<-"EOS" do
    #{ credential_str } \\
    openstack volume create \\
    --size #{ volume['size'].to_s } \\
    #{ volume['name'] }
  EOS
    not_if <<-"EOS"
      #{ credential_str } openstack volume show #{ volume['name'] }
    EOS
  end
end

