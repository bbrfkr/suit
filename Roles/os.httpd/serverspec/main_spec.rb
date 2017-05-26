require './Modules/spec_helper_serverspec'
require './Modules/defaults'
property.reverse_merge!(defaults_load(__FILE__))

describe ("os.httpd") do
  describe ("check httpd package is installed") do
    describe package("httpd") do
      it { should be_installed }
    end
  end
end
