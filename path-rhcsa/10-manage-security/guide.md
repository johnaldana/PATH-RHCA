# 10 - Manage Security

This section covers essential system security tasks required for a Red Hat Enterprise Linux administrator. 

By the end of this section, you should be able to:

- Configure and manage firewall rules using `firewalld` and `firewall-cmd`
- Control network access using zones, services, ports, and rich rules
- Manage default file permissions using `umask`
- Configure secure SSH access using key-based authentication
- Enable and disable password authentication for SSH
- Understand and manage SELinux modes (enforcing, permissive, disabled)
- Identify SELinux file and process contexts
- Restore default SELinux contexts using `restorecon`
- Manage SELinux port labeling using `semanage`
- Modify SELinux behavior using booleans

---

## 10.1. Configure Firewall Settings using firewall-cmd / firewalld

### Basic Commands

```bash
# Check firewall status
sudo firewall-cmd --state
sudo systemctl status firewalld

# List all active zones
sudo firewall-cmd --get-active-zones

# List all zones
sudo firewall-cmd --get-zones

# Show current zone configuration (default zone)
sudo firewall-cmd --get-default-zone
sudo firewall-cmd --zone=public --list-all

# List services and ports allowed in a zone
sudo firewall-cmd --zone=public --list-services
sudo firewall-cmd --zone=public --list-ports

# Add a service permanently
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh

# Add a port permanently
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=3306/tcp

# Remove service/port
sudo firewall-cmd --permanent --remove-service=http
sudo firewall-cmd --permanent --remove-port=8080/tcp

# Reload firewall (apply permanent changes)
sudo firewall-cmd --reload

# Change default zone
sudo firewall-cmd --set-default-zone=internal

# Create and use a custom zone
sudo firewall-cmd --permanent --new-zone=myzone
sudo firewall-cmd --permanent --zone=myzone --set-target=ACCEPT
sudo firewall-cmd --permanent --zone=myzone --add-source=192.168.10.0/24
sudo firewall-cmd --reload

# Assign interface to zone
firewall-cmd --zone=internal --change-interface=eth0

# Add source to zone (IMPORTANT in exam)
firewall-cmd --zone=internal --add-source=192.168.1.0/24 --permanent

firewall-cmd --runtime-to-permanent
```
### Rich Rules

```bash
# Allow SSH only from specific network
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept'

# Drop all traffic from a specific IP
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="203.0.113.50" drop'

# Log and reject
sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="10.0.0.0/8" log prefix="DROPPED: " level="warning" reject'
```
---

## 10.2. Manage Default File Permissions (umask)

```bash
# Check current umask
umask
umask -S                    # Makes the output symbolic

# Temporary change
umask 0027
umask 0077

# Make permanent (for all users)
echo 'umask 0027' | sudo tee -a /etc/profile
echo 'umask 0027' | sudo tee -a /etc/bashrc

# For specific user
echo 'umask 0077' >> ~/.bashrc
```
**Common umask values:**

- `0022` → Default (files 644, dirs 755)
- `0027` → Good security (files 640, dirs 750)
- `0077` → Very restrictive (files 600, dirs 700)

---

## 10.3. Configure Key-Based Authentication for SSH

**On the Client (generate keys)**

```bash
ssh-keygen -t ed25519 -C "user@workstation"
# or for RSA (older systems)
# ssh-keygen -t rsa -b 4096 -C "user@workstation"

# Copy public key to server
ssh-copy-id user@server-ip
```

**On the Server (harden SSH)**

```bash
sudo vim /etc/ssh/sshd_config
```
```bash
#conf
Key settings to change:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
PermitEmptyPasswords no
MaxAuthTries 3
LoginGraceTime 20
```
```bash
# Restart SSH
sudo systemctl restart sshd
sudo systemctl enable sshd

# Verify
sudo sshd -t
```

**Critical Permissions for SSH Key-Based Authentication**

For SSH key-based authentication to function correctly, the OpenSSH daemon (sshd) enforces a strict security policy. If the file permissions are too permissive (meaning other users on the system could potentially read or modify them), the SSH server will ignore the keys and deny the connection to protect the account from being compromised.
Directorio ~/.ssh: 700 (drwx------)

**Permissions Breakdown**

| **File / Directory** | **Recommended Permission** | **Why it matters?** |
| :--- | :--- | :--- |
| ~/.ssh/| 700 (drwx------) |Only the owner should be able to enter this directory to list or access key files. |
| authorized_keys | 600 (-rw-------) | This file contains the public keys allowed to log into your account. If others can write to it, they could add their own keys and gain access. | 
| id_ed25519 | 600 (-rw-------) | This is your Private Key. It is like your physical house key. If the system detects that it is world-readable, SSH will block its use for security reasons. | 

---

## 10.4. SELinux - Set Enforcing and Permissive Modes

```bash
# Check current mode
sestatus
getenforce

# Temporary change
sudo setenforce 0          # Permissive
sudo setenforce 1          # Enforcing

# Permanent change (edit config)
sudo vim /etc/selinux/config

# Change this line:
SELINUX=enforcing
# or
SELINUX=permissive
# or
SELINUX=disabled

# Reboot required for permanent change
sudo reboot

# Check SELinux denials
ausearch -m avc -ts recent

# Human-readable output
sealert -a /var/log/audit/audit.log

```
---

## 10.5. List and Identify SELinux File and Process Contexts

```bash
# File contexts
ls -Z
ls -lZ /etc /var /home

# Process contexts
ps -eZ
ps auxZ | grep httpd
ps -Z -C sshd

# View specific context
ls -Z /etc/ssh/sshd_config
ls -Zd /var/www/html
```

**Context Format**

`user:role:type:level`

**Common contexts:**

- `system_u:object_r:httpd_sys_content_t:s0` → Web content
- `system_u:object_r:sshd_exec_t:s0` → SSH daemon
- `unconfined_u:object_r:user_home_t:s0` → User files

---

## 10.6. Restore Default File Contexts

```bash
# Restore single file/directory
sudo restorecon -v /var/www/html/index.html
sudo restorecon -v /etc/ssh/sshd_config

# Recursive restore
sudo restorecon -Rv /var/www/html
sudo restorecon -Rv /home

# See what would be changed (dry run)
sudo restorecon -Rv -n /var/www

# Use semanage to see default contexts
sudo semanage fcontext -l | grep httpd
sudo semanage fcontext -l | grep ssh
```
---

## 10.7 Manage SELinux Port Labels

```bash
# List current port labels
sudo semanage port -l | grep -E 'http|ssh|mysql'

# Add a new port for httpd (example: 8080)
sudo semanage port -a -t http_port_t -p tcp 8080

# Add multiple ports
sudo semanage port -a -t http_port_t -p tcp 8080-8090

# Delete a port label
sudo semanage port -d -t http_port_t -p tcp 8080

# Change existing port type
sudo semanage port -m -t ssh_port_t -p tcp 2222
```

**Most Important SELinux Contexts (RHCSA)**

**Web / HTTP**
```bash
httpd_sys_content_t        # Static web content (read-only)
httpd_sys_rw_content_t     # Writable web content
httpd_sys_script_exec_t    # Executable scripts (CGI)
httpd_config_t             # Apache config files
httpd_log_t                # Apache logs
```

**Database (MariaDB / MySQL)**
```bash
mysqld_db_t                # Database files
mysqld_log_t               # Database logs
mysqld_var_run_t           # Runtime files (PID, sockets)
mysqld_etc_t               # Config files
```

**SSH**
```bash
sshd_exec_t                # SSH daemon binary
sshd_config_t              # SSH config file
ssh_home_t                 # User SSH files (~/.ssh)
```

**User / Home**
```bash
user_home_t                # User home directories
user_tmp_t                 # User temporary files
```

**System / General**
```bash
etc_t                      # /etc configuration files
var_log_t                  # Log files
var_t                      # General /var content
tmp_t                      # Temporary files (/tmp)
```

**Network Services**
```bash
http_port_t                # HTTP ports (80, 8080)
ssh_port_t                 # SSH ports (22)
```
---

## 10.8 Use Boolean Settings to Modify SELinux Behavior

```bash
# List all booleans
getsebool -a
semanage boolean -l

# Search specific boolean
getsebool -a | grep httpd
getsebool -a | grep ftp
getsebool -a | grep ssh

# Check current value
getsebool httpd_can_network_connect
getsebool allow_ftpd_full_access

# Enable boolean temporarily
setsebool httpd_can_network_connect 1

# Enable permanently
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_can_network_connect_db 1
setsebool -P ftpd_anon_write 1

# Disable
setsebool -P httpd_can_sendmail 0
```

**Most Important Booleans (RHCSA)**

```bash
httpd_can_network_connect
httpd_can_network_connect_db
httpd_can_sendmail
httpd_execmem
httpd_use_nfs
httpd_use_cifs
ftpd_anon_write
ftpd_full_access
nfs_export_all_ro
nfs_export_all_rw
samba_enable_home_dirs
ssh_chroot_full_access
use_nfs_home_dirs
```

