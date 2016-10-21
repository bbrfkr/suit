# Role Name: docker

## abstract
Install and setup docker.

## procedures
1. install docker
2. set listen port and tls setting
3. enable and start service

## tests
1. check package is installed
2. check service is enabled and running
3. check specified ports are listened
4. check tls is enabled or disabled
5. check the location of certificate directory

## parameters
```
---
docker:
  listen:
    - protocol: tcp                  # listen protocol
      address: 0.0.0.0               # iisten address
      port: 2375                     # listen port
    - protocol: unix                 # listen protocol
      address: /var/run/docker.sock  # listen address
  tls:
    enable: no                       # enable tls
    cert_dir: /etc/docker            # directory in which certificate is put
```

## supported os
* CentOS 7
