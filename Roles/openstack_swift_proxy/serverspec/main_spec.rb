require './Modules/spec_helper_serverspec'
require './Modules/defaults'
property.reverse_merge!(defaults_load(__FILE__))

scripts_dir = property['openstack_swift_proxy']['scripts_dir']

script = "source #{ scripts_dir }/admin-openrc &&"

describe ("openstack_swift_proxy") do
  describe ("check swift user is created") do
    describe command("#{ script } openstack user list") do
      its(:stdout) { should match /swift/ }
    end
  end

  describe ("check grant admin role to swift user") do
    describe command("#{ script } openstack role list --project service --user swift | awk '{ print $4 }'") do
      its(:stdout) { should match /admin/ }
    end
  end

  describe ("check swift service entity is created") do
    describe command("#{ script } openstack service list") do
      its(:stdout) { should match /swift/ }
    end
  end

  describe ("check endpoints for swift are created") do
    describe command("#{ script } openstack endpoint list | grep swift") do
      its(:stdout) { should match /public/ }
      its(:stdout) { should match /internal/ }
      its(:stdout) { should match /admin/ }
    end
  end

  describe ("check swift packages are installed") do
    packages = ["openstack-swift-proxy", "python2-swiftclient", \
                "python-keystoneclient", "python-keystonemiddleware", \
                "memcached"]
    packages.each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
  end
end
