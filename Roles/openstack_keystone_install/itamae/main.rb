require './Modules/defaults'
require './Modules/blockinfile'
node.reverse_merge!(defaults_load(__FILE__))

mariadb_pass = node['openstack_keystone_install']['mariadb_pass']
keystone_dbpass = node['openstack_keystone_install']['keystone_dbpass']
admin_token = node['openstack_keystone_install']['admin_token']
controller = node['openstack_keystone_install']['controller']

# create database
execute <<-"EOS" do
  mysql -uroot -p#{ mariadb_pass } -e "CREATE DATABASE keystone;"
EOS
  not_if <<-"EOS"
    mysql -uroot -p#{ mariadb_pass } -e "show databases;" | grep keystone
  EOS
end

execute <<-"EOS" do
  mysql -uroot -p#{ mariadb_pass } -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '#{ keystone_dbpass }';"
EOS
  not_if <<-"EOS"
    mysql -uroot -p#{ mariadb_pass } -e "show grants for 'keystone'@'localhost'" | grep "ALL PRIVILEGES ON \\`keystone\\`.* TO 'keystone'@'localhost'"
  EOS
end

execute <<-"EOS" do
  mysql -uroot -p#{ mariadb_pass } -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '#{ keystone_dbpass }';"
EOS
  not_if <<-"EOS"
    mysql -uroot -p#{ mariadb_pass } -e "show grants for 'keystone'@'%'" | grep "ALL PRIVILEGES ON \\`keystone\\`.* TO 'keystone'@'%'"
  EOS
end

# install packages
packages = ["openstack-keystone", "httpd", "mod_wsgi"]
packages.each do |pkg|
  package pkg do
    action :install
  end
end

# modify config file
file "/etc/keystone/keystone.conf" do
  action :edit
  block do |content|
    section = "[DEFAULT]"
    settings = <<-"EOS"
admin_token = #{ admin_token }
    EOS
    blockinfile(section, settings, "MANAGED BY ITAMAE (openstack_keystone_install, DEFAULT)", content)
  end
end

file "/etc/keystone/keystone.conf" do
  action :edit
  block do |content|
    section = "[database]"
    settings = <<-"EOS"
connection = mysql+pymysql://keystone:#{ keystone_dbpass }@#{ controller }/keystone
    EOS
    blockinfile(section, settings, "MANAGED BY ITAMAE (openstack_keystone_install, database)", content)
  end
end

file "/etc/keystone/keystone.conf" do
  action :edit
  block do |content|
    section = "[token]"
    settings = <<-"EOS"
provider = fernet
    EOS
    blockinfile(section, settings, "MANAGED BY ITAMAE (openstack_keystone_install, token)", content)
  end
end

