# Role Name: openstack_network

## abstract
This role executes basic network setting for openstack environment.

## procedures
1. disable NetworkManager
2. disable firewalld
3. set hostname (hook reboot)
4. edit hosts
5. edit resolv.conf
6. disable PEERDNS

## tests (serverspec)
1. check hostname
2. check hosts entries are available
3. check dns servers are set
4. check be able to access internet

## tests (infrataster)
nothing

## parameters
```
---
openstack_network:
  hostname: localhost.localdomain                                                   # hostname
  hosts_entries:
    - server: 'localhost localhost.localdomain localhost4 localhost4.localdomain4'  # name of server
      ip: '127.0.0.1'                                                               # address of server
    - server: 'localhost6 localhost6.localdomain6'                                  # name of server
      ip: '::1'                                                                     # address of server
  dns_servers:
    - server: 8.8.8.8                                                               # address of dns server
    - server: 8.8.4.4                                                               # address of dns server

```

## supported os
* CentOS 7
