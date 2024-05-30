### To address the issue of GitHub repeatedly asking for your username and password despite having created a token and configured SSH key authentication, follow these steps to ensure your setup is correct:

#### Step 1: Verify Your SSH Key Configuration
01. Check if the SSH key is added to the ssh-agent:

Open a terminal and run the following commands:
```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa  # Adjust the key file name if different
```

02. Add your SSH key to your GitHub account:

Copy the contents of your SSH public key to the clipboard:

```sh
cat ~/.ssh/id_rsa.pub  # Adjust the key file name if different
```
Log in to GitHub, go to Settings > SSH and GPG keys, and click New SSH key. Paste your key there and save.

#### Step 2: Set the Remote URL to Use SSH
Ensure your Git repository's remote URL is set to use SSH instead of HTTPS:

01. Check the current remote URL:

```sh
git remote -v
```

If it's using HTTPS, change it to SSH:
```sh
git remote set-url origin git@github.com:username/repo.git
# Replace username with your GitHub username and repo with the repository name.
```
#### Step 3: Cache Your GitHub Credentials (For HTTPS)

If you need to use HTTPS and prefer using a personal access token, you can cache your credentials using Git's credential helper:

01. Store your credentials using a credential helper:

```sh
git config --global credential.helper cache
```

02. Alternatively, store credentials permanently (use with caution):
```sh
git config --global credential.helper store
# When prompted for the username and password, enter your GitHub username and the personal access token as the password.
```

### Step 4: Troubleshooting
Ensure your SSH agent is running:

The SSH agent needs to be running to manage your keys. You can start it with:

```sh
eval "$(ssh-agent -s)"
```

Check your SSH connection:

Verify that you can connect to GitHub using SSH:
```sh
ssh -T git@github.com
```

You should see a message like:
```vbnet
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

If you've followed these steps and continue to experience issues, it may be helpful to double-check the permissions on your SSH keys, ensure the SSH key is correct, or restart your terminal or computer to ensure all changes take effect.

#### Step 5: Example Commands
```bash
# Start the SSH agent
eval "$(ssh-agent -s)"

# Add your SSH key to the agent
ssh-add ~/.ssh/id_rsa

# Set the remote URL to SSH
git remote set-url origin git@github.com:username/repo.git

# Cache HTTPS credentials
git config --global credential.helper cache

# Store HTTPS credentials permanently (if needed)
git config --global credential.helper store

# Test the SSH connection
ssh -T git@github.com
```
By ensuring your SSH key is correctly added and your Git remote URL is set to use SSH, you should be able to push to GitHub without being prompted for a username and password.