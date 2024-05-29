#To get all information for host "Node04"
ansible all -m gather_facts --limit node04

# To get OS details for host "Node04"
ansible all -m gather_facts --limit node04 | grep ansible_distribution
