# 10. Manage Security - Tasks

## Task 1: Restrict Web Application Access by Network

Your company deployed an internal web application on port `8080`. Access must be restricted to the corporate network only (`10.0.0.0/8`).

**Requirements:**

- Allow access to port `8080` using the firewall

- Restrict access only to the `10.0.0.0/8` network

- Keep the default zone active

- Make the configuration persistent

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash  
  sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.0.0.0/8" port port="8080" protocol="tcp" accept'

  sudo firewall-cmd --list-ports

  sudo firewall-cmd --permanent --remove-port=8080/tcp

  sudo firewall-cmd --reload
  sudo firewall-cmd --list-all
  ```
</details>

---

## Task 2: Restrict SSH Access to Office Network

A security audit found that **SSH is exposed** to the entire internet.

**Requirements:**

- Restrict SSH access to `192.168.10.0/24` only

- Block all other incoming SSH connections

- Apply changes permanently using the firewall

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash 
  sudo firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.10.0/24" service name="ssh" accept'

  sudo firewall-cmd --permanent --remove-service=ssh

  sudo firewall-cmd --get-active-zones

  sudo firewall-cmd --reload
  sudo firewall-cmd --list-all
  ```
</details>

---

## Task 3: Apply Firewall Changes Safely

You added temporary firewall rules for testing a database service.

**Requirements:**

- Reload firewall rules without interrupting active connections

- Ensure all rules are properly applied

- Verify configuration in the active zone

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash 
  sudo firewall-cmd --reload
  sudo firewall-cmd --get-active-zones
  sudo firewall-cmd --list-all
  ```
</details>

---

## Task 4: Secure Default File Permissions

Developers are creating files with overly permissive access (`666`).

**Requirements:**

- Configure a secure default umask for all users

- Ensure new files are not world-readable

- Apply the configuration system-wide

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash 
  echo 'umask 0027' | sudo tee -a /etc/profile
  echo 'umask 0027' | sudo tee -a /etc/bashrc

  umask
  ```
</details>

---

## Task 5: Restrict Access to Audit Logs

Audit logs in `/var/log/audit` are readable by the wheel group.

Requirements:

- Ensure new files in this directory are only readable by root

- Adjust default permission behavior

- Maintain compliance with strict access policies

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash 
  chmod 600 /var/log/audit/*
  chown root:root /var/log/audit/*
  chmod 700 /var/log/audit
  ```
</details>

---

## Task 6: Enforce SSH Key-Based Authentication Only

To mitigate brute-force attacks, password authentication must be disabled.

**Requirements:**

- Disable password authentication in SSH

- Ensure only key-based authentication is allowed

- Apply settings for all users, including root

- Validate SSH configuration before restarting the service

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  
  sudo vim /etc/ssh/sshd_config
  
  PermitRootLogin no
  PasswordAuthentication no
  PubkeyAuthentication yes
  PermitEmptyPasswords no

  sshd -t
  systemctl enable sshd.service
  systemctl restart sshd.service
  systemctl status sshd  
    
  ```
</details>

---

## Task 7: Configure Passwordless SSH for Automation

A monitoring server needs passwordless SSH access to execute scripts.

**Requirements:**

- Generate an SSH key pair for a service account

- Deploy the public key to the target server

- Ensure secure permissions on SSH directories and files

- Validate passwordless login


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ssh-keygen -t ed25519 -C "user@workstation"
  ssh-copy-id user@server-ip   

  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/authorized_keys

  ssh user@server-ip
  ```
</details>

---

## Task 8: Troubleshoot SELinux Blocking (Temporary Permissive)

A newly installed application is blocked by SELinux.

**Requirements:**

- Temporarily switch SELinux to permissive mode

- Collect logs related to the denial

- Return SELinux to enforcing mode after troubleshooting

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  setenforce 0
  journalctl | grep AVC
  ausearch -m avc -ts recent
  journalctl -xe | grep AVC
  setenforce 1   
  ```
</details>

---

## Task 9: Enforce SELinux Mode Permanently

All servers must run in enforcing mode per company policy.

**Requirements:**

- Verify current SELinux mode

- Set SELinux to enforcing if needed

- Ensure configuration persists after reboot


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  getenforce
  setenforce 1

  sudo vim /etc/selinux/config
  # Change this line:
  SELINUX=enforcing
  reboot
  ```
</details>

---

## Task 10: Diagnose SELinux File Context Issues

Apache cannot access files in `/etc/webapp` despite correct Linux permissions.

**Requirements:**

- Inspect SELinux contexts of the directory and files

- Identify incorrect labeling

- Determine why access is denied

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ls -lZ /etc/webapp
  semanage fcontext -a -t httpd_sys_content_t "/etc/webapp(/.*)?"
  restorecon -vR /etc/webapp

  ls -dZ /etc/webapp
  ```
</details>

---

## Task 11: Verify SELinux Process Context

The httpd process is behaving unexpectedly.

**Requirements:**

- Identify the SELinux context of the running process

- Confirm it is running in the correct domain

- Compare with expected context

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ps auxZ | grep httpd

  ps -ZC httpd
 
  ```
</details>

---

## Task 12: Restore SELinux Contexts for Web Content

Files copied into /var/www/html are causing access errors.

**Requirements:**

- Restore default SELinux contexts recursively

- Ensure web server can access the content

- Verify proper labeling

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ls -lZ /var/www/html
  
  restorecon -vR /var/www/html
 
  ```
</details>

---

## Task 13: Restore Context for a Single File

The MariaDB service is failing to start. Investigation shows that the configuration file `/etc/my.cnf` has an incorrect SELinux context.

**Requirements:**

- Identify the SELinux context issue
- Restore the default context for `/etc/my.cnf` only
- Do not modify other files in `/etc`
- Ensure the `mariadb` service starts successfully

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ls -lZ /etc/my.cnf

  restorecon -v /etc/my.cnf

  systemctl restart mariadb
  systemctl status mariadb
   
  ```
</details>

---

## Task 14: Configure SELinux Port for Custom Application

An application runs on port 8443 but is blocked by SELinux.

**Requirements:**

- Assign the correct SELinux port type

- Ensure the application runs without denials

- Maintain SELinux in enforcing mode

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
   # Check existing ports
  semanage port -l | grep http

  # Add port (if not exists)
  semanage port -a -t http_port_t -p tcp 8443

  # If already exists → modify
  semanage port -m -t http_port_t -p tcp 8443

  # Verify
  semanage port -l | grep 8443   
  ```
</details>

---

## Task 15: Enable SELinux Boolean for Database Connectivity

A web server needs to connect to a remote PostgreSQL database.

**Requirements:**

- Identify the relevant SELinux boolean

- Enable the required behavior

- Keep SELinux enforcing

- Ensure connectivity works

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # Identify relevant booleans
  getsebool -a | grep httpd

  # Enable outbound network connections for httpd
  setsebool -P httpd_can_network_connect on

  # Verify
  getsebool httpd_can_network_connect
  ```
</details>