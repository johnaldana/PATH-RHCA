# 04-Operate Running Systems – Guide

This guide focuses on real-world system operation on RHEL 9 / AlmaLinux 9. All tasks are performed using the command line only and align with RHCSA objectives.

---

## 4.1. Boot, Reboot, and Shut Down a System Normally

```bash
# Shutdown the system immediately
sudo poweroff
sudo shutdown -h now
```

```bash
# Reboot the system
sudo reboot
sudo shutdown -r now
```

```bash
# Schedule shutdown/reboot
sudo shutdown -h +10 "System will power off in 10 minutes"
sudo shutdown -r 22:00 "Scheduled reboot"
```

**Notes:**

- shutdown notifies logged-in users.

- poweroff and reboot are direct commands (systemctl poweroff/reboot are equivalent).

---

## 4.2. Boot Systems into Different Targets Manually

RHEL 9 uses systemd targets instead of runlevels.

```bash
# Show current default target
systemctl get-default

# Switch to graphical target
sudo systemctl isolate graphical.target

# Switch to multi-user target (console mode)
sudo systemctl isolate multi-user.target

# Set graphical as default permanently
sudo systemctl set-default graphical.target
```

**Important targets:**

- graphical.target → GUI

- multi-user.target → console/multi-user mode

- rescue.target → rescue mode

- emergency.target → minimal emergency mode

---

## 4.3. Interrupt the Boot Process to Gain Access

**Use case:** Forgot root password or need rescue access.

**Steps (GRUB2, UEFI/BIOS):**

1. Reboot and access GRUB menu (Shift or Esc).

2. Select the kernel entry and press e to edit.

3. Find the line starting with linux or linuxefi.

   ```bash
   #Append at the end:
   
   rd.break
   ```

4. Press Ctrl+X to boot.

5. Emergency shell opens. Mount root filesystem as read/write:

   ```bash
   mount -o remount,rw /sysroot
   chroot /sysroot
   passwd   # change root password
   touch /.autorelabel   # if SELinux is enabled — very important!
   exit
   exit                  # continue booting
   reboot
   ```

---

## 4.4. Identify CPU/Memory Intensive Processes and Kill Processes

```bash
# Monitor CPU/memory in real-time
top
htop    # if installed

# Top 10 CPU-consuming processes
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
ps aux --sort=-%cpu | head

# Top 10 memory-consuming processes
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
ps aux --sort=-%mem | head
```

**Kill processes:**

```bash
kill <PID>             # normal termination SIGTERM
kill -9 <PID>          # force termination SIGKILL
pkill -9 httpd         # Kill process by name
pkill -u maria         # Kill all processes of a user
pgrep -u root sshd     # Finds PIDs for sshd owned by root
```

---

## 4.5. Adjust Process Scheduling

Use nice and renice for priority:

```bash
# Start process with priority
nice -n 10 myscript.sh   # lower priority
nice -n -5 myscript.sh   # higher priority, requires root

# Change priority of a running process
renice 5 -p <PID>
```

**Note:** nice values: -20 (highest priority) → 19 (lowest priority).

---

## 4.6. Manage Tuning Profiles

**Tool:** tuned

```bash
# Check tuned service status
systemctl status tuned

# List available profiles
tuned-adm list

# Show active profile
tuned-adm active

# Apply a profile
sudo tuned-adm profile throughput-performance
sudo tuned-adm profile balanced
```

**Common profiles:**

```bash
tuned-adm profile virtual-guest            # common for VMs
tuned-adm profile throughput-performance   # BD - maximum performance
tuned-adm profile powersave
tuned-adm profile latency-performance      # low latency
tuned-adm profile balanced                 # default in many cases
tuned-adm off                              # disable tuned
```
**Note:** tuned profiles may slightly differ depending on hardware and virtualization environment.

---

## 4.7. Locate and Interpret System Log Files and Journals

**Traditional log files:** /var/log/

```bash
/var/log/messages   # system messages
/var/log/secure     # authentication logs
/var/log/dnf.log    # package manager logs
/var/log/cron       # cron jobs
```

**Using journalctl (systemd):**

```bash
# Full journal
journalctl

# Last 50 entries
journalctl -n 50

# Logs for a specific service
journalctl -u sshd

#kernel messages
journalctl -k

# Logs since last boot
journalctl -b

#Errors from current boot (-b)
journalctl -p err -b

#Since specific date
journalctl -u sshd --since "2026-02-01"

# Follow logs in real-time
journalctl -f

#How much space journals use
journalctl --disk-usage

#Deleted logs
journalctl --vacuum-size=500M
journalctl --vacuum-time=7d
```
---

## 4.8. Preserve System Journals

```bash
# Backup journal
journalctl > /root/journal_backup.log

# Make journal persistent
sudo mkdir -p /var/log/journal
sudo systemd-tmpfiles --create --prefix /var/log/journal
sudo systemctl restart systemd-journald

# Adjust retention in /etc/systemd/journald.conf
# SystemMaxUse=500M
# MaxRetentionSec=1month
#Storage=persistent
```

---

## 4.9. Start, Stop, and Check Status of Network Services

**Example: SSH**

```bash
# Start service
sudo systemctl start sshd

# Stop service
sudo systemctl stop sshd

# Restart service
sudo systemctl restart sshd

# Check status
systemctl status sshd

# Enable/disable at boot
sudo systemctl enable sshd
sudo systemctl disable sshd

# Reload config (no disconnect)
systemctl reload sshd

# See all running services
systemctl list-units --type=service --state=running

# See failed units
systemctl --failed
```

**Check open ports:**

```bash
ss -tuln
netstat -tulnp   # if installed
```

---

## 4.10. Securely Transfer Files Between Systems

**Using SCP:**

```bash
# Local → Remote
scp /path/to/localfile user@remote:/path/to/destination

# Remote → Local
scp user@remote:/path/to/remotefile /path/to/localdestination
```

**Using SFTP:**

```bash
sftp user@remote
# commands inside sftp:
get remotefile
put localfile
exit
```

**Using Rsync (efficient):**

```bash
rsync -avz /local/dir/ user@remote:/remote/dir/
```

**Note:** /dir copies the folder, while /dir/ copies the contents of the folder.

**Use SSH key (most secure)**

```bash
ssh-keygen
ssh-copy-id user@server     #No password needed after
```



