require './Modules/defaults'
node.reverse_merge!(defaults_load(__FILE__))

# install packages
packages = ["memcached", "python-memcached"]
packages.each do |pkg|
  package pkg do
    action :install
  end
end

# enable and start service
service "memcached" do
  action [:enable, :start]
end

