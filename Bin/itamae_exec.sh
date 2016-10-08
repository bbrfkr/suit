#!/usr/bin/env ruby
require 'yaml'
require 'expect'
require 'pty'
require 'fileutils'
require 'io/console'

WORK_DIR = "Env/work_itamae"

def itamae_exec(mode, verbose)
  if mode == "exec" || mode == "test"
    connections = YAML.load_file('Env/inventory.yml')
    if File.exists?('Env/properties.yml')
      if File.empty?('Env/properties.yml')
        properties = YAML.load_file('Env/properties.yml')
      end
    end
    
    FileUtils.mkdir_p(WORK_DIR)
    
    connections.each do |connection|
      if properties != nil
        if properties[connection['conn_name']] != nil
          property = properties[connection['conn_name']]
          property_file = WORK_DIR + "/" + connection['conn_name'] + ".yml"
          open(property_file,"w") do |f|
            YAML.dump(property,f)
          end
        end
      end
    
      connection['roles'].each do |role|
        cmd = "itamae ssh -h #{ connection['conn_host'] }" \
              + " -u #{ connection['conn_user'] }" \
              + " -p #{ connection['conn_port'] }" \
              + (mode == "test" ? " -n" : "") \
              + (property_file != nil ? " -y #{ property_file }" : "") \
              + (connection['conn_idkey'] != nil ? " -i Env/#{ connection['conn_idkey'] }" : "") \
              + (verbose ? " -l debug" : "") \
              + " Roles/#{ role }/itamae/main.rb"
    
        pty = PTY.getpty(cmd)
    
        if connection['conn_idkey'] == nil
          pty[0].expect(/password:/,10) do |line|
            puts line
            system "stty -echo"
            sleep 0.1
            pty[1].puts connection['conn_pass']
            sleep 0.1
            system "stty echo"
          end
        end
    
        begin
          while( true )
            puts pty[0].gets
          end
        rescue Errno::EIO => e
        end
    
      end
    end
    
    FileUtils.rmtree(WORK_DIR)
  else
    puts ("ERROR: specify 'exec' or 'test' as mode")
    exit 1
  end  
end

if ARGV.count > 2 || ARGV.count == 0
  puts "ERROR: invalid number of arguments"
  exit 1
end

if ARGV[1] == "-V"
  itamae_exec(ARGV[0],true)
elsif ARGV[1] == nil 
  itamae_exec(ARGV[0],false)
else
  puts "ERROR: unknown option #{ARGV[1]}"
  exit 1
end

