require './Modules/defaults'
require './Modules/blockinfile'
node.reverse_merge!(defaults_load(__FILE__))

package "httpd" do
  action :install
end

