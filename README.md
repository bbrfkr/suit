# suit 
SUIT: Simply Usable Infrastructure Template

## abstract
SUIT is simply usable Infrastructure as Code library. SUIT contains itamae, serverspec and infrataster codes.

## download  
    
```
$ git clone https://github.com/bbrfkr/suit
```

## install
1. Install dependent package.  

    ```
    # gem install itamae serverspec infrataster activesupport
    ```
2. Change directory to suit repository.  

    ```
    $ cd suit
    ```
3. Check `Bin/suit` command is executable.  
    ```
    $ Bin/suit
    suit: Simply Usable Infrastructure Template 
    
    === Usage === 
    * Bin/suit [-h] [-v]
        -h : show this help message
        -v : show version

    * Bin/suit role list
        show installed role list

    * Bin/suit role params ROLE
        show default parameters of the specified role

    * Bin/suit itamae exec [-V]
        execute itamae
        -V : with verbose output

    * Bin/suit itamae test [-V]
        dry-run itamae
        -V : with verbose output

    * Bin/suit serverspec exec
        execute serverspec

    * Bin/suit infrataster exec
        execute infrataset
    ```

## usage

### create inventory
Inventory is a file with information for suit to connect target server. this file is written as follow;

```
- conn_name: entry01
  conn_host: 192.168.0.1
  roles:
    - role01
  conn_user: root
  conn_pass: password
  conn_port: 22
 
- conn_name: entry02
  conn_host: 192.168.0.2
  roles:
    - role02
  conn_user: root
  conn_pass: password
  conn_port: 22
```
