require './Modules/defaults'
node.reverse_merge!(defaults_load(__FILE__))

reboot_flag = false
reboot_waittime = node['openstack_network']['reboot_waittime']

# disable NetworkManager
service "NetworkManager" do
  action [:disable, :stop]
end

# disable firewalld
service "firewalld" do
  action [:disable, :stop]
end

# disable SELINUX
selinux = run_command("grep /etc/selinux/config -e \"^SELINUX=disabled$\"", error: false).exit_status
if selinux != 0
  file "/etc/selinux/config" do
    action :edit
    block do |content|
      content.gsub!(/^SELINUX=.*$/, "SELINUX=disabled")
    end
  end
  reboot_flag = true
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
      content.gsub!(/^PEERDNS="?yes"?/, "PEERDNS=no")
    end
  end
end

# for restarting network
service "network"

# reboot server when hostname or selinux state is changed
local_ruby_block "reboot server" do
  block do
    begin
      if reboot_flag
        opt = { :port => ENV['CONN_PORT'] }
        if ENV['CONN_IDKEY'] != nil
          opt[:keys] = ["Env/" + ENV['CONN_IDKEY']]
        end
        if ENV['CONN_PASSPHRASE'] != nil
          opt[:passphrase] = ENV['CONN_PASSPHRASE']
        end
        if ENV['CONN_PASS'] != nil
          opt[:password] = ENV['CONN_PASS']
        end
        Net::SSH.start(ENV['CONN_HOST'], ENV['CONN_USER'], opt) do |ssh|
          if ENV['CONN_USER'] == "root"
            ssh.exec "reboot"
          else
            channel = ssh.open_channel do |ch|
              channel.request_pty do |ch, success|
                raise "could not obtain pty" if !success
              end
              channel.exec "sudo reboot"
            end
            ssh.loop
          end
        end
      end
    rescue IOError
      puts "\e[31m***************************************************\e[0m"
      puts "\e[31mrebooting server is required!! \e[0m"
      puts "\e[31mserver is rebooted. please wait for #{ reboot_waittime } minutes... \e[0m"
      puts "\e[31m***************************************************\e[0m"
      sleep(reboot_waittime * 60)
    end
  end
end
