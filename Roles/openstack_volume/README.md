# Role Name: openstack_volume

## abstract
This role executes creating cinder volume of openstack environment.

## procedures
1.  create volume

## tests (serverspec)
1.  check volume is active
2.  check volume name is appropriate
3.  check volume size is appropriate

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
```

## supported os
* CentOS 7
