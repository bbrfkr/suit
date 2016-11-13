require './Modules/defaults'
node.reverse_merge!(defaults_load(__FILE__))

reboot_flag = false
wait_for_reboot = 3

# disable NetworkManager
service "NetworkManager" do
  action [:disable, :stop]
end

# disable firewalld
service "firewalld" do
  action [:disable, :stop]
end

# set hostname
hostname = run_command("uname -n").stdout.chomp
if hostname != node['openstack_network']['hostname']
  execute "echo #{ node['openstack_network']['hostname'] } > /etc/hostname"
  reboot_flag = true
end

# edit hosts
template "/etc/hosts" do
  action :create
  source "templates/hosts.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(hosts_entries: node['openstack_network']['hosts_entries'])
end

# edit resolv.conf
template "/etc/resolv.conf" do
  action :create
  source "templates/resolv.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(dns_servers: node['openstack_network']['dns_servers'])
end

# disable PEERDNS
nics = run_command("ip addr | grep -e 'state' | awk '{ print $2 }'").stdout.split(":\n")
nics.each do |nic|
  file "/etc/sysconfig/network-scripts/ifcfg-#{ nic }" do
    action :edit
    notifies :restart, "service[network]"
    block do |content|
      content.gsub!(/^PEERDNS=yes/, "PEERDNS=no")
    end
  end
end

# for restarting network
service "network"

# reboot server when hostname is changed
if reboot_flag
  execute "shutdown -r"
  local_ruby_block "caution reboot" do
    block do
      puts "\e[31m***** server will be rebooted. please wait for #{ wait_for_reboot } minutes... *****\e[0m"
      sleep(wait_for_reboot * 60)
    end
  end
end

