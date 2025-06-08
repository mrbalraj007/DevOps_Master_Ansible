#!/bin/bash

# Update package lists
apt update

# Install required packages for Ansible agent
apt install -y python3 python3-pip openssh-server

# Enable and start SSH service
systemctl enable ssh
systemctl start ssh

# Create .ssh directory
mkdir -p /home/ubuntu/.ssh

# Add the master's public key to authorized_keys
# Note: In a production environment, you would use a more secure method
# such as a configuration management tool or user data populated with the key
cat >> /home/ubuntu/.ssh/authorized_keys << 'EOL'
# Add the public key from the Ansible master manually or using a different method
# The public key will be available in the Ansible master's output
EOL

# Set correct permissions
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys

# Allow password authentication temporarily (you can disable this later)
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

echo "Ansible agent setup complete"
