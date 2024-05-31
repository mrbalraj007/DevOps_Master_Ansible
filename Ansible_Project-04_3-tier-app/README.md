# 3-tier application Ansible project
 
 Here’s an end-to-end guide:

 ## Project Structure

    Here's the project structure we will use:

```css
[dc-ops@controller Ansible_Project-04_3-tier-app]$ tree
.
├── ansible.cfg
├── inventory
│   └── hosts
│       └── hosts.ini
├── playbooks
│   ├── app.yml
│   ├── db.yml
│   ├── master.yml
│   └── web.yml
├── README.md
└── roles
    ├── app
    │   ├── files
    │   ├── handlers
    │   │   └── main.yml
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    ├── db
    │   ├── files
    │   ├── handlers
    │   │   └── main.yml
    │   ├── tasks
    │   │   └── main.yml
    │   └── templates
    └── web
        ├── files
        ├── handlers
        │   └── main.yml
        ├── tasks
        │   └── main.yml
        └── templates
```

### Configuration Files
    ansible.cfg
```ini
[dc-ops@controller Ansible_Project-04_3-tier-app]$ cat ansible.cfg
[defaults]
inventory = inventory/hosts
#remote_user = dc-ops
roles_path = roles
#host_key_checking = False
```

### inventory/hosts

```ini
[web]
Node01
Node02

[app]
Node03

[db]
Node04
Node05
```
