require './Modules/defaults'
require './Modules/blockinfile'
node.reverse_merge!(defaults_load(__FILE__))

scripts_dir = node['openstack_swift_proxy']['scripts_dir']
domain = node['openstack_swift_proxy']['domain']
swift_pass = node['openstack_swift_proxy']['swift_pass']
region = node['openstack_swift_proxy']['region']
controller = node['openstack_swift_proxy']['controller']

script = "source #{ scripts_dir }/admin-openrc &&"

# create swift user
execute "#{ script } openstack user create --domain #{ domain } --password #{ swift_pass } swift" do
  not_if "#{ script } openstack user list | grep swift"
end

# grant admin role to swift user
execute "#{ script } openstack role add --project service --user swift admin" do
  not_if "#{ script } openstack role list --project service --user swift | awk '{ print $4 }' | grep admin"
end

# create swift service entity
execute "#{ script } openstack service create --name swift --description \"OpenStack Object Storage\" object-store" do
  not_if "#{ script } openstack service list | grep \"swift\""
end

# create endpoints for swift
execute "#{ script } openstack endpoint create --region #{ region } object-store public http://#{ controller }:8080/v1/AUTH_%\\(tenant_id\\)s" do
  not_if "#{ script } openstack endpoint list | grep swift | grep public"
end

execute "#{ script } openstack endpoint create --region #{ region } object-store internal http://#{ controller }:8080/v1/AUTH_%\\(tenant_id\\)s" do
  not_if "#{ script } openstack endpoint list | grep swift | grep internal"
end

execute "#{ script } openstack endpoint create --region #{ region } object-store admin http://#{ controller }:8080/v1" do
  not_if "#{ script } openstack endpoint list | grep swift | grep admin"
end

# install packages
packages = ["openstack-swift-proxy", "python2-swiftclient", "python-keystoneclient", \
            "python-keystonemiddleware", "memcached"]
packages.each do |pkg|
  package pkg do
    action :install
  end
end

# put config file
template "/etc/swift/proxy-server.conf" do
  action :create
  source "templates/proxy-server.conf.erb"
#  owner "root"
#  group "root"
#  mode "0644"
  variables(controller: controller, \
            domain: domain, \
            swift_pass: swift_pass)
end

