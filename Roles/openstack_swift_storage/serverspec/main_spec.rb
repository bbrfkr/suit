require './Modules/spec_helper_serverspec'
require './Modules/defaults'
property.reverse_merge!(defaults_load(__FILE__))

swift_devs = property['openstack_swift_storage']['swift_devs']
mount_points_dir = property['openstack_swift_storage']['mount_points_dir']

describe ("openstack_swift_storage") do
  describe ("check xfsprogs and rsync are installed") do
    packages = ["xfsprogs", "rsync"]
    packages.each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
  end

  describe ("check sepcified devices are mounted") do
    swift_devs.each do |dev|
      describe file("#{ mount_points_dir }/#{ dev }") do
        it { should be_mounted.with( :device => "/dev/#{ dev }" ) }
        it { should be_mounted.with( :type => "xfs" ) }
      end
    end
  end

  describe ("check rsyncd is enabled and running") do
    describe service("rsyncd") do
      it { should be_enabled }
      it { should be_running }
    end 
  end

  describe ("check swift packages are installed") do
    packages = ["openstack-swift-account", "openstack-swift-container", \
                "openstack-swift-object"]
    packages.each do |pkg|
      describe package(pkg) do
        it { should be_installed }
      end
    end
  end

  describe ("check owner of mount points directory is swift") do
    describe command("(ls -ld #{ mount_points_dir } && ls -lR #{ mount_points_dir }) | grep -e \"[d|-]\\([r|-][w|-][x|-]\\)\\{3\\}\" | grep -v \"swift swift\"") do
      its(:exit_status) { should_not eq 0 }
    end
  end

  describe ("check owner and permission to recon directory") do
    describe command("(ls -ld /var/cache/swift && ls -lR /var/cache/swift) | grep -e \"[d|-]\\([r|-][w|-][x|-]\\)\\{3\\}\" | grep -v \"root swift\"") do
      its(:exit_status) { should_not eq 0 }
    end

    describe command("(ls -ld /var/cache/swift && ls -lR /var/cache/swift) | grep -e \"[d|-]\\([r|-][w|-][x|-]\\)\\{3\\}\" | grep -v -e \"[d|-]rwxrwxr-x\"") do
      its(:exit_status) { should_not eq 0 }
    end
  end
end
