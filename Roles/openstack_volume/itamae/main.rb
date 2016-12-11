require './Modules/defaults'
require './Modules/blockinfile'
require './Modules/openstack_credential'
node.reverse_merge!(defaults_load(__FILE__))

volumes = node['openstack_volume']['volumes']
credential_str = openstack_credential(node['openstack_volume']['credential'])

def detach_volume(credential_str, vol_name)
  execute <<-"EOS" do
    #{ credential_str } \\
    openstack server remove volume \\
    `#{ credential_str } openstack volume list | \\
    grep #{ vol_name } | \\
    awk '{ print $12 }'` \\
    #{ vol_name }
  EOS
    only_if <<-"EOS"
      #{ credential_str } openstack volume list | grep #{ vol_name } | grep in-use
    EOS
  end
end

# create volumes
volumes.each do |volume|

  # check prameter "state"
  if volume['state'] != "present" && volume['state'] != "absent"
    fail 'parameter "state" should be "present" or "absent" '
  end

  if volume['state'] == "present"
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

    if volume['attached_instance'] != nil
      execute <<-"EOS" do
        #{ credential_str } \\
        openstack server add volume \\
        #{ volume['attached_instance'] } \\
        #{ volume['name'] }
      EOS
        not_if <<-"EOS"
          #{ credential_str } openstack volume list | \\
          grep #{ volume['name'] } | \\
          grep #{ volume['attached_instance'] } 
        EOS
      end
    else
      detach_volume(credential_str, volume['name'])
    end
  end

  if volume['state'] == "absent"
    detach_volume(credential_str, volume['name'])

    execute <<-"EOS" do
      #{ credential_str } \\
      openstack volume delete #{ volume['name'] }
    EOS
      only_if <<-"EOS"
        #{ credential_str } openstack volume show #{ volume['name'] }
      EOS
    end
  end
end

