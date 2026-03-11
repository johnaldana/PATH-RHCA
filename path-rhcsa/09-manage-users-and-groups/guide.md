# 09 - Manage Users and Groups

This section covers the essential tasks for handling identity and access management on a Red Hat Enterprise Linux system.

**Objectives Covered:**

- Create, delete, and modify local user accounts
- Change passwords and adjust password aging for local user accounts
- Create, delete, and modify local groups and group memberships
- Configure privileged access

---

## 9.1. Create, Delete, and Modify Local User Accounts

Linux systems control access through **users and groups**.

Each user has:

- UID (User ID)
- Username
- Home directory
- Login shell
- Password

Groups allow administrators to **manage permissions for multiple users efficiently**.

**Important System Files**

| **File** | **Purpose** |
|-----|--------|
| `/etc/passwd` | Basic user account information |
| `/etc/shadow` | Encrypted passwords |
| `/etc/group` | Group definitions |
| `/etc/gshadow` | Group security information |
| `/etc/default/useradd` | Default values for new users |
| `/etc/skel/` | Directory containing default files copied to a new user's home |


**Example entry in `/etc/passwd`:**

```bash
#Format: username:password:UID:GID:comment:home_directory:shell

john:x:1001:1001:John Doe:/home/john:/bin/bash
```

**Key Commands**

- **Create a user:** `useradd [options] username`
  
  - Options: 
    
    - -m (create home dir)
    - -d /path/to/home (custom home)
    - -s /bin/bash (shell)
    - -u UID (custom UID)
    - -g group (primary group)
    - -G group1,group2 (supplementary groups)
    - -c "Comment" (GECOS field)
    - -e YYYY-MM-DD (expiration date).

- **Modify a user:** `usermod [options] username` 

  - Options: Similar to useradd, plus:
  
    - -l newname (rename)
    - -L (lock account)
    - -U (unlock).

- **Delete a user:** `userdel [options] username`

  - Options: 
    
    - -r (remove home dir and mail spool).

**Examples**

```bash
# Creating Users
sudo useradd anna                                       # Create a basic user
sudo useradd -m anna                                    # Create user with home directory
sudo useradd -s /bin/bash anna                          # Create user with specific shell
sudo useradd -u 1050 anna                               # Create user with specific UID
sudo useradd -c "Database Administrator" anna           # Add description/comment

id anna                                                 # Check creation
# Output example:
uid=1001(anna) gid=1001(anna) groups=1001(anna),1002(developers) 

# Modifying Users
sudo usermod -s /bin/zsh anna                           # Change user shell
sudo usermod -d /data/anna -m anna                      # Change home directory
sudo usermod -aG developers anna                        # Add user to a group

# -aG -a  means append. Without it, existing groups will be overwritten.

# Deleting Users
sudo userdel anna                                # Delete a user
sudo userdel -r anna                             # Delete a user including the home directory

```
---

## 9.2. Change Passwords and Adjust Password Aging for Local User Accounts

Passwords are managed in `/etc/shadow`. Aging policies control expiration, minimum age, etc., to enforce security. Tools like `chage` adjust these.

**Key Commands**

- **Change password:** `passwd [username]`
  
  - Interactive; prompts for new password.
  - Options: 
  - 
    - -l (lock)
    - -u (unlock)
    - -d (delete password, allowing login without one—use cautiously).

- **Adjust aging:** `chage [options] username`
  
  - Options: 

    - -m days (min days between changes)
    - -M days (max days before expiration)
    - -W days (warning days)
    - -I days (inactive days before lock)
    - -E YYYY-MM-DD (account expiration)
    - -l (list current settings).

**Examples**

```bash
sudo passwd alice                          # Set password for alice
#Interactive
#Enter new password twice.

sudo chage -M 90 -m 7 -W 14 alice          # Set aging: Max 90 days, min 7 days, warn 14 days

sudo chage -l alice                        # View aging
#Example output includes:
# - Last password change
# - Password expiration
# - Account expiration
# - Minimum days between changes
# - Maximum days between changes

sudo passwd -e alice                       # Expire password immediately
```

**Best Practices**

- Enforce complex passwords via `/etc/security/pwquality.conf`.
- Set global defaults in `/etc/login.defs`.
- Monitor with last or lastlog for inactive accounts.

---

## 9.3. Create, Delete, and Modify Local Groups and Group Memberships

Groups are defined in:

- `/etc/group` → group information
- `/etc/gshadow` → group security information

Each user has:

- **Primary group** → defined in `/etc/passwd`
- **Supplementary groups** → defined in `/etc/group`

The primary group is used by default when the user creates files. GIDs similar to UIDs.
Supplementary groups provide additional permissions.

**Key Commands**

- **Create a group:** `groupadd [options] groupname`
  
  - Options: 
  
    - -g GID (custom GID)
    - -r (system group, low GID)

- **Modify a group:** `groupmod [options] groupname`
  
  - Options: 
  
    - -n newname (rename)
    - -g newGID (change GID).

- **Delete a group:** `groupdel groupname`

- **Manage memberships:**

  - Add user: `usermod -aG group username` or `gpasswd -a username group`
  - Remove user: `gpasswd -d username group`
  - Set group password: `gpasswd group` (allows non-members to join temporarily with newgrp).

**Examples**

```bash
sudo groupadd developers                        # Creating Groups
sudo groupadd -g 2000 developers                # Create group with specific GID

sudo groupmod -n devteam developers             # Change group name
sudo groupmod -g 3000 devteam                   # Change group ID

sudo groupdel developers                        # Deleting Groups

groups anna                                     # Show groups for a user
groups                                          # Show groups for current user

sudo usermod -g developers anna                 # Changing Primary Group

# Temporarily switch the primary group in the current shell.
newgrp developers 
```
---

# 9.4. Configure Privileged Access

Privileged access uses sudo for temporary root privileges without sharing root password. Configured in `/etc/sudoers` (edit with visudo). Supports aliases for users, hosts, commands.

**The `wheel` Group**

By default in RHEL, members of the wheel group have full sudo privileges.

`usermod -aG wheel jdoe`

Never edit `/etc/sudoers` directly with a text editor.

**Custom Sudoers Configuration**

Avoid editing `/etc/sudoers` directly. Instead, create files in `/etc/sudoers.d/` for modularity and professionalism.

- **Run the editor safely:** `visudo -f /etc/sudoers.d/accounting`

- **Syntax Examples:**

    - **Full access (no password):** 
          
          user      host run-as         command
          username  ALL=(ALL) NOPASSWD: ALL

    - **Specific command for a group:** %finance ALL=/usr/bin/dnf
  

**Checking Sudo Privileges**

`sudo -l`

Displays the commands a user is allowed to run with sudo.
