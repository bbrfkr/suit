require './Modules/defaults'
node.reverse_merge!(defaults_load(__FILE__))

# $6$ means hash type is SHA-512
user 'change root password'do
  username "root"
  password node['vagrant_root']['root_password'].crypt('$6$')
end
