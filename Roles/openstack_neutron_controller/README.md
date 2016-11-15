# Role Name: openstack_neutron_controller

## abstract
This role executes install and setting neutron for controller node.

## procedures
1.  create neutron database
2.  grant privileges to access database
3.  create neutron user
4.  add admin role to neutron user
5.  create neutron service entity
6.  create endpoints for neutron
7.  install packages
8.  edit config file
9.  create keyfiles dir
10. create plugin.ini symbolic link
11. deploy service database
12. reboot openstack-nova-api service
13. enable and start services

## tests (serverspec)
1.  check neutron database are created
2.  check privileges of database is set
3.  check neutron user is created
2016/11/15
4.  check admin role is granted to nova user
5.  check nova service entity is created
6.  check endpoints for nova are created
7.  check packages are installed
8.  check servcie databases is deployed
9. check services are enabled and started

## tests (infrataster)
nothing

## parameters
```
---
openstack_nova_controller:
  mariadb_pass: password            # root password of mariadb
  novadb_pass: password             # password of nova databases
  scripts_dir: /root/openrc_files   # location of openrc files
  nova_pass: password               # password of nova user
  domain: default                   # domain name of openstack environment
  region: RegionOne                 # region name of openstack environment
  controller: localhost             # hostname or ip of controller node
  mgmt_ip: 127.0.0.1                # ip of management network for controller node
  rabbitmq_pass: password           # password of openstack user for rabbitmq
  keyfiles_dir: /var/suit_keyfiles  # location of keyfiles
```

## supported os
* CentOS 7
