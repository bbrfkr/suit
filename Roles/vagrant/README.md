# Role Name: vagrant

## abstract
Install vagrant.

## procedures
1. install vagrant

## tests (serverspec)
1. check package is installed

## tests (infrataster)
nothing

## parameters
```
---
vagrant:
  rpm_url: https://releases.hashicorp.com/vagrant/1.8.6/vagrant_1.8.6_x86_64.rpm  # vagrant rpm url
```

## supported os
* CentOS 7
