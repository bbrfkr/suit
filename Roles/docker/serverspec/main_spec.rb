require './Modules/spec_helper_serverspec'
require './Modules/defaults'
property.reverse_merge!(defaults_load(__FILE__))

describe ("docker") do
  describe ("check packages are installed") do
    describe package("docker") do
      it { should be_installed }
    end
  end

  describe ("check service is enabled") do
    describe service("docker") do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe ("check specified ports are listened") do
    property['docker']['listen'].each do |listen|
      if listen['protocol'] == "unix"
        describe file(listen['address']) do
          it { should be_socket }
        end
      else
        describe port(listen['port']) do
          if listen['address'] == "0.0.0.0" or listen['address'] == "::"
            it { should be_listening.on("0.0.0.0").with(listen['protocol']).or\
                 be_listening.on("::").with(listen['protocol'] + "6") }
          else
            it { should be_listening.on(listen['address']).with(listen['protocol']).or\
                 be_listening.on(listen['address']).with(listen['protocol'] + "6") }
          end
        end
      end
    end
  end

  if property['docker']['tls']['enable'] == true
    describe ("check tls is enabled") do
      describe file("/etc/sysconfig/docker") do
        its(:content) { should match /^OPTIONS.*--tlsverify'$/ }
      end
    end
  elsif property['docker']['tls']['enable'] == false
    describe ("check tls is disabled") do
      describe file("/etc/sysconfig/docker") do
        its(:content) { should_not match /^OPTIONS.*--tlsverify'$/ }
      end
    end
  end

  if property['docker']['tls']['cert_dir'] != nil
    describe ("check the location of cert dir") do
      describe file("/etc/sysconfig/docker") do
        its(:content) { should match /DOCKER_CERT_PATH=#{ property['docker']['tls']['cert_dir'] }/}
      end
    end
  end
end

