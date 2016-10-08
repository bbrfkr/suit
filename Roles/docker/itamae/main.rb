require './Modules/defaults'
node.reverse_merge!(defaults_load(__FILE__))

package "docker" do
  action :install
end

template "/etc/sysconfig/docker" do
  action :create
  variables(listens: node['docker']['listen'],\
            tls: node['docker']['tls'])
  notifies :restart, "service[docker]"
end

service "docker" do
  action [:enable, :start]
end
