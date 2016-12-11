# Role Name: openstack_volume

## abstract
This role executes creating cinder volume of openstack environment.

## procedures
* if you want to create volume,
  1.  create volume
  2.  attach volume to instance if you want to do that
* if you want to delete volume,
  1.  detach volume from instance if volume is attached
  2.  delete volume

## tests (serverspec)
* if you want to create volume,
  1.  check volume is active
  2.  check volume name is appropriate
  3.  check volume size is appropriate
  4.  check volume is attached to appropriate instance
* if you want to delete volume,
  1.  check volume doesn't exist

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
  volumes:
    - name: myvolume                     # name of volume 
      size: 1                            # size of volume
      attached_instance: myinstance      # instance to which volume is attached
      state: present                     # state of volume ("present" or "absent")
```

## supported os
* CentOS 7
