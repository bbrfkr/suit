# Role Name: vagrant_root

## abstract
Against virtual machine created by vagrant, this role change the password of root user.

## procedures
1. change root password

## tests
nothing

## parameters
```
---
vagrant_root:
  root_password: password   # root password
```

## supported os
* CentOS 7
