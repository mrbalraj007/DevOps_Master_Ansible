#!/bin/bash

# Update package lists
apt update

# Install Ansible
apt install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible python3-pip tree jq

# Install AWS CLI and boto3 for dynamic inventory
pip3 install boto3 awscli

# Create ansible config directory
mkdir -p /etc/ansible
mkdir -p /home/ubuntu/.ssh
mkdir -p /etc/ansible/inventory

# Create a basic inventory file
cat > /etc/ansible/hosts << EOL
[local]
localhost

[agents]
# This will be populated dynamically 
EOL

# Create a simple ansible.cfg file
cat > /etc/ansible/ansible.cfg << EOL
[defaults]
inventory = /etc/ansible/hosts/
host_key_checking = False
private_key_file = /home/ubuntu/.ssh/ansible_key
remote_user = ubuntu

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

[inventory]
enable_plugins = aws_ec2
EOL



# Create a dynamic inventory file for AWS
cat > /etc/ansible/aws_ec2.yaml << EOL
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
filters:
  tag:Role: agent
  instance-state-name: running
compose:
  ansible_host: public_ip_address
keyed_groups:
  - key: tags.Name
    prefix: name
  - key: tags.Role
    prefix: tag_Role

EOL

# Generate SSH key for connecting to agent nodes
ssh-keygen -t rsa -b 4096 -C "Ansible-master" -f /home/ubuntu/.ssh/ansible_key -N ""
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/ansible_key
cp /home/ubuntu/.ssh/ansible_key.pub /home/ubuntu/.ssh/authorized_keys

# Output the public key for reference
echo "Use the following public key for agent nodes:"
cat /home/ubuntu/.ssh/ansible_key.pub

# Create a test playbook
cat > /etc/ansible/test_playbook.yml << EOL
---
- name: Test Ansible Connection
  hosts: tag_Role_agent
  become: yes
  tasks:
    - name: Ping test
      ping:
    
    - name: Get hostname
      command: hostname
      register: hostname_output
    
    - name: Display hostname
      debug:
        var: hostname_output.stdout
EOL

# Set proper ownership of the playbook
chown -R ubuntu:ubuntu /etc/ansible

# chown ubuntu:ubuntu /etc/ansible/inventory/test_playbook.yml
# chown ubuntu:ubuntu /etc/ansible/inventory/*

# Test the dynamic inventory:
ansible-inventory --list

# Direct testing of this inventory source
ansible-inventory -i /etc/ansible/aws_ec2.yaml --list

# git clone repo
cd /home/ubuntu/
git clone "https://github.com/mrbalraj007/Ansible-VM-Monitor.git" || {
  echo "Git clone failed, exiting..."
  exit 1
}

# Sleep for 30 sec after clone completes
echo "Repository cloned successfully, sleeping for 30 sec..."
sleep 30
echo "Sleep completed, continuing execution..."

cd Ansible-VM-Monitor
# Set proper permissions for the cloned repository
chown -R ubuntu:ubuntu /home/ubuntu/Ansible-VM-Monitor

# Test the dynamic inventory:
ansible-inventory --list

# Direct testing of this inventory source
ansible-inventory -i /home/ubuntu/Ansible-VM-Monitor/inventory/aws_ec2.yaml --list


# Copying the public key to the agent nodes is a manual step
cat > /home/ubuntu/copy_pubkey.sh << EOL
  #!/bin/bash

  # Define vars
  PEM_FILE="nameoffile.pem"
  PUB_KEY=$(cat ~/.ssh/ansible_key.pub)
  USER="ubuntu"  # or ec2-user
  INVENTORY_FILE="/home/ubuntu/Ansible-VM-Monitor/inventory/aws_ec2.yaml"
  # Extract hostnames/IPs from dynamic inventory
    HOSTS=$(ansible-inventory -i $INVENTORY_FILE --list | jq -r '._meta.hostvars | keys[]')
    for HOST in $HOSTS; do
    echo "Injecting key into $HOST"
    ssh -o StrictHostKeyChecking=no -i $PEM_FILE $USER@$HOST "
      mkdir -p ~/.ssh && \
      echo \"$PUB_KEY\" >> ~/.ssh/authorized_keys && \
      chmod 700 ~/.ssh && \
      chmod 600 ~/.ssh/authorized_keys
      " 
      done

EOL

# change the owner ship to Ubuntu
chown -R ubuntu:ubuntu /home/ubuntu/copy_pubkey.sh

echo "Ansible master setup complete"
