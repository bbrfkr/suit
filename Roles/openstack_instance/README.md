# Role Name: openstack_instance

## abstract
This role executes creating instance of openstack environment.

## CAUTION!!
This role cannot associate plural floating ips with instance.

## procedures
* if you want to create instance,
  1.  if user data exists, create temporary directory
  2.  if user data exists, send user data file to temporary directory
  3.  create instance
* if you want to delete instance,
  1.  delete instance

## tests (serverspec)
* if you have created instance,
  1.  check instance is active
  2.  check instance name is appropriate
  3.  check image used by instance is appropriate
  4.  check falvor used by instance is appropriate
  5.  check security groups set to instance is appropriate
  6.  check key pair set to instance is appropriate
  7.  check network used by instance is appropriate
  8.  check floating ip is added or removed for instance

* if you have deleted instance,
  1.  check instance doesn't exist

## tests (infrataster)
nothing

## parameters
```
---
openstack_instance:
  credential:
    project_domain: default              # domain name in which project joined 
    user_domain: default                 # domain name in which user joined
    project: demo                        # project name of openstack environment
    user: demo                           # user name of openstack environment
    password: password                   # password of user
    auth_url: http://controller:5000/v3  # url to authenticate
    identity_api_version:  3             # api version for identity service
    image_api_version: 2                 # api version for image service
  tmp_dir: /tmp/openstack_instances      # location of temporary directory
  instances:
    - image: cirros                      # image name used for instance
      flavor: m1.tiny                    # flavor used for instance
      security_groups:                   # list of security groups being applied to instance  
        - default
      key_pair: mykey                    # key pair name used for instance
      network: selfservice               # network name used by instance
      name: myinstance                   # name of instance
      floating_ip:                       # floating ip associated with instance (if this key is empty no floating ip is associated with instance)
      user_data:                         # name of user data file
      state: present                     # state of instance ("present" or "absent")
```

## supported os
* CentOS 7
