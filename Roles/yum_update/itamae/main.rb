require './Modules/defaults'
node.reverse_merge!(defaults_load(__FILE__))

# execute yum update
execute "yum update -y"

