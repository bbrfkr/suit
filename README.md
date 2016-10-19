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

### directory architecture
SUIT has the following directory architecture;
```
suit/
 ├ Bin/
 │  └ suit
 ├ Env/
 │  ├ inventory.yml
 │  └ properties.yml
 ├ Modules/
 └ Roles/
    └ [role_name]/
```
The explanation of each directory and file as follow;
* Bin/suit  
The body of `Bin/suit` command. Through this command, you can execute itamae, severspec and infrataster.
* Env/inventory.yml  
A file with information for suit to connect target server.
* Env/properties.yml  
A file with parameters which are used in itamae, serverspec and infrataster.
* Modules/  
In this directory, the common code used by suit is put.
* Roles/[role_name]/  
The body of role whose name is [role_name].

### view defined roles
To view the roles defined in suit, execute the following command.
```
$ Bin/suit role list
```
If you want to see the detail of the roles(abstract, procedures and parameters), look at the following address;  
https://github.com/bbrfkr/suit/tree/master/Roles/[the_name_of_role]

### create inventory.yml
`inventory.yml` is a yaml file with information for suit to connect target server. Before using suit, you have to set inventory.yml in `Env/` directory.

this file is written as follow;

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
    - role03
  conn_user: root
  conn_pass: password
  conn_port: 22
```
Each key means the following;
* conn_name  
The name of connection. We can name the connection an arbitrary name.
* conn_host  
The target server'S hostname or ip address.
* roles  
Roles wanted to apply to the target server.
* conn_user  
The user which is used when connect to target server.
* conn_pass  
The password with the user specified in `conn_user`
* conn_port  
The port number which is used when connect to target server.

### create properties.yml
`properties.yml` is a yaml file with parameters which are used in itamae, serverspec and infrataster. This file is written as follow;
```
entry01:
  role01:
    role01_parameter01: test01
    role01_parameter02: test02    

entry02:
  role02:
    role02_parameter01: test03
  role03:
    role03_parameter01: test04
    role03_parameter02: test05
    role03_parameter03: test06
```
The top level key should have the same value of `conn_name` in `inventory.yml`. The second level key should have a role name. The more level keys and values are the parameters and values used in each role. To create `properties.yml` easily, you can get the default parameters of each role by executing the following command;
```
$ Bin/suit role params [role_name]
```

### execute itamae
After setting `inventory.yml` and `properties.yml`, execute the only following command for executing itamae;
```
$ Bin/suit itamae exec
```

### execute serverspec
For executing serverspec, execute the only following command;
```
$ Bin/suit serverspec exec
```

### execute infrataster
For executing infrataster, execute the only following command;
```
$ Bin/suit infrataster exec
```
