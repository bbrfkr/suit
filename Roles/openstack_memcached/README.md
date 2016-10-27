# Role Name: openstack_memcached

## abstract
This role executes installing and setting memcached for openstack environment.

## procedures
1. install memcached packages
2. enable and start memcached

## tests (serverspec)
1. check memcached packages are installed
2. check memcached service is running and enabled

## tests (infrataster)
nothing

## parameters
nothing

## supported os
* CentOS 7
