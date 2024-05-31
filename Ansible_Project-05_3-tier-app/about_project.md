#  3-tier Application project in Ansible

#### Infra Setup:
``` css
Server:
ansible-core version 2.14
```

``` css 
Client Machine: 
Hostname: Node01 OS: NAME="Red Hat Enterprise Linux" VERSION="9.2 (Plow)"
Hostname: Node02 OS: NAME="Red Hat Enterprise Linux" VERSION="9.2 (Plow)"
Hostname: Node03 OS: NAME="Red Hat Enterprise Linux" VERSION="9.2 (Plow)"
Hostname: Node04 OS: PRETTY_NAME="Ubuntu 24.04 LTS"
Hostname: Node05 OS: "Debian GNU/Linux 12 (bookworm)" NAME="Debian GNU/Linux"
```

## Project Structure:
```python
│
├── inventories/
│   └── production/
│       ├── hosts                   # Inventory file
│       └── group_vars/
│           └── all.yml             # Group variables
│
├── roles/
│   ├── webserver/
│   │   ├── tasks/
│   │   │   └── main.yml           # Tasks for configuring web servers
│   │   ├── templates/             # Jinja2 templates for web server configuration
│   │   └── defaults/              
│   │       └── main.yml           # Default variables for the web server role
│   │
│   ├── database/
│   │   ├── tasks/
│   │   │   └── main.yml           # Tasks for configuring database servers
│   │   └── defaults/
│   │       └── main.yml           # Default variables for the database role
│   │
│   └── application/
│       ├── tasks/
│       │   └── main.yml           # Tasks for deploying the application
│       └── files/                 
│           └── app.jar            # Application artifact
│
└── playbooks/
    ├── setup.yml                  # Main playbook to set up the infrastructure
    └── deploy.yml                 # Secondary playbook to deploy the application
```
#### Explanation:

##### ansible.cfg: 
```shell
[defaults]
inventory = inventories/production/hosts
roles_path = roles
```

##### Inventories: 
``` ini
Contains inventory files for different environments (e.g., production, staging) and group variables that apply to all hosts in the inventory.

[webservers]
Node01
Node02
Node03

[databases]
Node04

[applications]
Node01
Node02
Node03
Node04
Node05
```

##### Roles: 
``` ini 
Organizes tasks, variables, and files related to specific server configurations.
In our case, we have three roles: webserver, database, and application.
```

##### webserver: 
``` ini
Configures the web servers (Node01, Node02, Node03).
```

##### database: 
``` ini
Configures the database server (Node04).
```
##### application: 
``` ini
Manages the deployment of the application on all nodes.
```

#### Playbooks:

```yml
setup.yml: Main playbook responsible for setting up the infrastructure.

deploy.yml: Secondary playbook that deploys the application after infrastructure setup is complete.
```

