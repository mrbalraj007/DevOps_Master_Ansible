#!/bin/bash

# List of remote machines
REMOTE_HOSTS=("node01" "node02" "node03" "node04")

# SSH user
USER="dc-ops"

# Path to your public key (default is ~/.ssh/id_rsa.pub)
PUB_KEY_PATH="/home/dc-ops/.ssh/id_rsa.pub"

# Loop through each host and copy the SSH key
for HOST in "${REMOTE_HOSTS[@]}"; do
  echo "Copying SSH key to $USER@$HOST"
  ssh-copy-id -i $PUB_KEY_PATH $USER@$HOST

  if [ $? -eq 0 ]; then
    echo "Successfully copied SSH key to $USER@$HOST"
  else
    echo "Failed to copy SSH key to $USER@$HOST"
  fi
done

