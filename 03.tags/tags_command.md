# To check the all tags run the below query:
```bash
ansible-playbook --list-tags install_package_with_two_distribution_when_Condition_tags.yml
```

# if you want to execute specific command on any server then rafer the tags and execute the command
```bash 
ansible-playbook --tags ubuntu install_package_with_two_distribution_when_Condition_tags.yml
``` 

# if I want to target multiple tags then command need to execute as below
```bash
ansible-playbook --tags ubuntu,RedHat install_package_with_two_distribution_when_Condition_tags.yml 
```
