# 07 - Deploy, Configure, and Maintain Systems - Guide

This section covers essential system administration tasks for the RHCSA exam (EX200) on Red Hat Enterprise Linux 9 / 10.

Key exam objectives covered:

- Schedule tasks using **at**, **cron**, and **systemd timer units**
- Start and stop services and configure services to start automatically at boot
- Configure systems to boot into a specific target automatically
- Configure time service clients
- Install and update software packages from Red Hat Content Delivery Network, a remote repository, or from the local file system
- Modify the system bootloader

---

## 7.1. Schedule Tasks Using at, cron, and systemd Timer Units

### at – One-time jobs
Execute a command once at a specific time.

If not installed:
```bash
dnf install at -y
systemctl enable --now atd
```

```bash
# Schedule a job (interactive)
at now + 5 minutes
at> /usr/local/bin/backup.sh
at> <EOT>   # Ctrl+D

# List pending jobs
atq

# Remove a job
atrm <job-number>

# View job content
at -c <job-number>
```
### cron – Recurring jobs
Managed by crond service.

```bash
#Check cron service
systemctl status crond
systemctl enable --now crond

#Edit current user crontab
crontab -e

#Cron format
* * * * * command
- - - - -
| | | | |
| | | | +---- day of week (0-7)
| | | +------ month (1-12)
| | +-------- day of month (1-31)
| +---------- hour (0-23)
+------------ minute (0-59)

#List cron jobs
crontab -l

#System-wide cron files
/etc/crontab
/etc/cron.d/
/etc/cron.daily/
/etc/cron.weekly/
/etc/cron.monthly/
```
### systemd Timers – Modern recurring tasks 
consists of two unit files: .service + .timer

```bash
# Example: Run backup every day at 3:00 AM

# 1. Create service unit
sudo vim /etc/systemd/system/backup.service
[Unit]
Description=Daily Backup Job

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh

# 2. Create timer unit
sudo vim /etc/systemd/system/backup.timer
[Unit]
Description=Run backup daily at 3 AM

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
Unit=backup.service
RandomizedDelaySec=15m 

[Install]
WantedBy=timers.target

#systemd-analyze calendar '*-*-* 03:00:00' for troubleshooting

# 3. Enable and start
sudo systemctl daemon-reload
sudo systemctl enable --now backup.timer

# Check status
systemctl list-timers --all
systemctl status backup.timer
```

---

## 7.2. Start and Stop Services – Configure to Start at Boot

Use `systemctl` to manage systemd services.

```bash
# Common commands
systemctl start httpd
systemctl stop httpd
systemctl restart httpd
systemctl reload httpd          # graceful reload if supported

systemctl enable httpd          # start at boot
systemctl disable httpd         # do NOT start at boot

systemctl is-enabled httpd
systemctl is-active httpd

# Mask service (cannot be started even manually)
systemctl mask firewalld
systemctl unmask firewalld

# List all running services
systemctl list-units --type=service --state=running

# View dependencies
systemctl list-dependencies multi-user.target
```

---

## 7.3. Configure Systems to Boot into a Specific Target Automatically.

Targets are groups of units that define the system state. Targets replace legacy runlevels.

**Common targets**

| **Target** | **mode** | **Equivalent Runlevel** |
| ------ | ---- | ---------------- |
| multi-user.target	| Text-based | 3 |
| graphical.target | GUI | 5 |
| rescue.target | Maintenance (single-user)| 1 |  
| emergency.target | Minimal (no services) | N/A |

```bash
# View current default target
systemctl get-default

# Set default target (persists after reboot)
systemctl set-default multi-user.target
systemctl set-default graphical.target

# Switch target immediately (no reboot)
systemctl isolate multi-user.target
systemctl isolate graphical.target

# List all targets
systemctl list-units --type=target
```

---

## 7.4. Configure Time Service (NTP)

RHEL uses chronyd to synchronize the system clock.

```bash
# Check status
systemctl status chronyd
systemctl enable --now chronyd

# Main configuration file
/etc/chrony.conf

# Example configurations
# Use public pool (default)
pool 2.rhel.pool.ntp.org iburst

# Use internal NTP server
server ntp.internal.company.com iburst

# Allow this host to serve time (server mode – optional)
allow 192.168.10.0/24

# After changes
systemctl restart chronyd

# Verify synchronization
chronyc sources -v
chronyc tracking
chronyc activity

# Displays current time, timezone, and NTP synchronization status.
timedatectl status
timedatectl set-timezone America/New_York
timedatectl set-ntp true  #Active chronyd
timedatectl set-time "2025-12-31 23:59:59"   
```

---

## 7.5. Install and Update Software Packages

dnf is the package manager for RHEL 9+.

```bash
# Register system
subscription-manager register
subscription-manager attach --auto

# List available repos
dnf repolist

# Install package
dnf install httpd

# Update all packages
dnf update

# Search package
dnf search git
dnf provides */git

# Package information:
dnf info httpd

# Remove
dnf remove httpd
```

**Install from Local RPM**

```bash
dnf install ./package.rpm
```
**Create a Local Repository**

```bash
mkdir /repo
cp *.rpm /repo
createrepo /repo
```
```bash
#vim /etc/yum.repos.d/local.repo
[local-repo]
name=Local Repo
baseurl=file:///repo
enabled=1
gpgcheck=0
```
```bash
dnf repolist
dnf install some-package
```

**From a remote repository (custom .repo)**

```bash
# Example /etc/yum.repos.d/custom.repo
[custom-repo]
name=Custom Repository
baseurl=http://repo.example.com/rhel9/
enabled=1
gpgcheck=0
```
```bash
dnf repolist
dnf install some-package
```
**From local file system (e.g., mounted ISO)**

```bash
# Mount ISO
mkdir /mnt/iso
mount -o loop rhel-9.2-x86_64-dvd.iso /mnt/iso

# Create repo file
cat <<EOF | sudo tee /etc/yum.repos.d/local.repo
[local-baseos]
name=Local BaseOS
baseurl=file:///mnt/iso/BaseOS
enabled=1
gpgcheck=0

[local-appstream]
name=Local AppStream
baseurl=file:///mnt/iso/AppStream
enabled=1
gpgcheck=0
EOF
```
```bash
dnf repolist
dnf install some-package
```

---

## 7.6. Modify the System Bootloader (GRUB2)

**Temporary change (single boot)**

- Reboot and interrupt GRUB (press any key if hidden)
- Select entry → press e to edit
- Go to line starting with linux or linux16
- Add/modify kernel parameters (e.g., rd.break, systemd.unit=rescue.target, quiet, nomodeset)
- Press Ctrl+X to boot with changes

**Permanent change**

```bash
# Method 1: Edit default kernel parameters
sudo vim /etc/default/grub
# Modify: GRUB_CMDLINE_LINUX="..."

# Regenerate GRUB config
sudo grub2-mkconfig -o /boot/grub2/grub.cfg          # BIOS
sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg  # UEFI

# Method 2: Add custom entry (advanced)
sudo vim /etc/grub.d/40_custom
# Then regenerate as above

grub2-set-default 0   # Set first entry as default
```


