require './Modules/defaults'
node.reverse_merge!(defaults_load(__FILE__))

package node['vagrant']['rpm_url'] do
  action :install
end
