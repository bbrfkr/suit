require './Modules/spec_helper_serverspec'
require './Modules/defaults'
property.reverse_merge!(defaults_load(__FILE__))

describe ("check vagrant is installed") do
  describe package("vagrant") do
    it { should be_installed }
  end
end

