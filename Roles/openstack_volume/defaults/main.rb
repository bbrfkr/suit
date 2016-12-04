---
openstack_volume:
  credential:
    project_domain: default
    user_domain: default
    project: demo
    user: demo
    password: password
    auth_url: http://controller:5000/v3
    identity_api_version:  3
    image_api_version: 2
  volumes:
    - name: myvolume
      size: 1

