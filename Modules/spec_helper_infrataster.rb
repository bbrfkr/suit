require 'infrataster/rspec'
require 'serverspec'

# dummy setting for avoid warning
set :backend, :ssh

connection = ENV['CONN_NAME']
if File.exists?('Env/properties.yml')
  if not File.zero?('Env/properties.yml')
    properties = YAML.load_file('Env/properties.yml')
    if properties[connection] != nil
      set_property properties[connection]
    else
      set_property {}
    end
  end
end

Infrataster::Server.define(ENV['CONN_NAME'].to_sym) do |server|
  server.address = ENV['CONN_HOST']
  if ENV['CONN_IDKEY'] != nil
    server.ssh = { user: ENV['CONN_USER'], keys: ["Env/" + ENV['CONN_IDKEY']], port: ENV['CONN_PORT'].to_i }
  else
    server.ssh = { user: ENV['CONN_USER'], password: ENV['CONN_PASS'], port: ENV['CONN_PORT'].to_i }
  end
end

