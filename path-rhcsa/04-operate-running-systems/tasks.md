# 04-Operate Running Systems – Tasks
**RHCSA – RHEL 9**

## Task 1 – Mitigate High CPU Usage Caused by PHP-FPM After Deployment

Production web server web-prd-05 is responding very slowly after deploying a new PHP application version.
top shows that multiple PHP-FPM child processes are consuming 70–95% CPU each.

### You must:

- Identify the top 5 CPU-consuming processes at the moment of investigation

- Identify the service/binary responsible for those processes

- Permanently lower the priority of all current and future php-fpm processes to nice value +10

- Perform the change without restarting the service

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # Identify the top 5 CPU-consuming processes at the moment of investigation
  ps -eo pid,ppid,user,ni,pcpu,pmem,comm --sort=-pcpu | head -6

  # Identify the service/binary responsible for those processes
  systemctl status php-fpm
  # OR find the binary path
  which php-fpm

  # Permanently lower the priority of all current and future php-fpm processes to nice value +10
  renice -n 10 $(pgrep -f php-fpm)                     #current processes
  systemctl set-property php-fpm.service Nice=10       #future processes
  
  #Perform the change without restarting the service
  systemctl daemon-reload
  ```
</details>

---

## Task 2 – Gracefully Stop Memory-Exhausting User Processes While Preserving SSH Access

User appuser started a memory-intensive R script on server report-qa-02.

**Current situation:**

- The process uses 28 GB of RAM out of 32 GB

- The system is heavily swapping

- The user is still logged in via one active SSH session

### You must:

- List all processes owned by appuser

- Gracefully terminate all processes except the SSH session

- Use SIGTERM only, unless absolutely unavoidable

- Confirm that swap usage starts decreasing after termination

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # List all processes owned by appuser
  pgrep -u appuser 

  # Gracefully terminate all processes except the SSH session
  pkill -u appuser -v -x "bash|sshd"

  # Confirm that swap usage starts decreasing after termination
  watch -d free -h
  
  ```
</details>

---

## Task 3 – Schedule 02:00 Kernel Maintenance Reboot With 30-Minute Advance Warning

Server **db-prod-03** is scheduled for security kernel updates **(RHSA-2026:1234)** during the approved maintenance window at **02:00.** As the lead sysadmin, you must ensure that all users are notified exactly 30 minutes before the system goes down.

### Requirements:

- Schedule a system reboot exactly at 02:00.

- Ensure all logged-in users receive a clear broadcast warning exactly 30 minutes before the reboot (sent at 01:30).

- Use the exact message below:

  ***“System db-prod-03 will be rebooted at 02:00 for urgent security kernel patching (RHSA-2026:1234). Please save your work and log out.”***

- The warning must be visible to all SSH sessions, console sessions, and remote terminals.

- The reboot must be protected from cancellation by non-privileged users.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #run at 01:30
  sudo shutdown -r 02:00 "System db-prod-03 will be rebooted at 02:00 for urgent security kernel patching \(RHSA-2026:1234\). Please save your work and log out."
  ```
</details>

---

## Task 4 – Restore Correct Default Boot Target After Misconfiguration

On the test server test-virt-14, a junior administrator accidentally set the default boot target to rescue.target. If the server reboots now, it will drop into an emergency maintenance mode instead of starting standard services. You must fix this configuration immediately without rebooting the server.

### You must:

- Identify the current default target

- Change the default target back to multi-user.target

- Do not reboot the server

- Verify that the new default target is correctly set

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # Identify the current default target
  systemctl get-default

  # Change the default target back to multi-user.target
  systemctl set-default multi-user.target

  # Verify that the new default target is correctly set
  systemctl get-default
  ```

</details>

---

## Task 5 – Recover Root Access Using GRUB on a Locked System

The root password for server **app-frontend-12** has been lost, and no other users have sudo privileges. You have console access (physical or VNC). You must regain root access while ensuring that SELinux does not block your login after the password change.

### Requirements:

- Interrupt the boot process at the GRUB menu.

- Gain emergency access to the system using the **rd.break** method.

- Reset the root password to **NewRootPass123.**

- Ensure SELinux context labels are restored so the new password is accepted by the system.

- Provide the full command sequence executed within the emergency shell.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #Edit grub, rd.break
  
  mount -o remount,rw /sysroot
  
  chroot /sysroot
  
  echo "NewRootPass123" | passwd --stdin root  # change root password
  
  touch /.autorelabel                          # if SELinux is enabled — very important!
  
  exit
  
  exit                                         # continue booting
  ```

</details>

---

## Task 6 – Configure Persistent Journald Storage for Audit Compliance

Security audit finding on server logstore-01:

- Journals are volatile

- Logs are stored only in /run/log/journal

### You must:

- Configure persistent journal storage in /var/log/journal

- Set maximum disk usage to 10 GB

- Retain logs for at least 90 days, or until the 10 GB limit is reached

- Apply the configuration without rebooting, if possible

- Verify that the new configuration is active

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # 1. Create the persistent directory and apply correct permissions/ownership
  mkdir -p /var/log/journal
  systemd-tmpfiles --create --prefix /var/log/journal
  
  # 2. Edit the journald configuration file
  vi /etc/systemd/journald.conf
  
  # Under the [Journal] section, modify or add:
  # Storage=persistent
  # SystemMaxUse=10G
  # MaxRetentionSec=90d
  
  # 3. Restart the service to apply changes
  systemctl restart systemd-journald

  # 4. Verification
  # Verify that the journal is now using /var/log/journal
  journalctl --disk-usage
  journalctl --verify
  ```

</details>

---

## Task 7 – Permanently Disable Graphical Mode on a Jump Host

Jump host jump-01 has GNOME installed.

**Current issue:**

- Users report very slow graphical sessions over RDP/VNC

**Decision:**

- The server should only be accessible via SSH

### You must:

- Permanently set the default boot target to multi-user.target

- Ensure the change persists after reboot

- Apply the change to the currently running system immediately without a full reboot.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # Permanently set the default boot target to multi-user.target
  systemctl set-default multi-user.target

  #Apply the change to the currently running system immediately without a full reboot.
  systemctl isolate multi-user.target

  # Check default boot target
  systemctl get-default
  ```

</details>

---

## Task 8 – Apply Correct Tuned Profile for a KVM Virtual Machine

The virtual machine vm-app-23 was deployed using a generic "golden image." As a result, it is still using the balanced performance profile. To ensure optimal performance within the KVM environment, you must switch it to the virtual-guest profile.

### You must:

- Identify the currently active tuned profile

- Change it to the recommended KVM profile: virtual-guest

- Ensure the profile becomes active immediately
  
- Show proof that the active profile has changed


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # Identify the currently active tuned profile
  tuned-adm active

  #Change it to the recommended KVM profile: virtual-guest
  tuned-adm profile virtual-guest

  # Ensure the profile becomes active immediately
  tuned-adm active

  # Show proof that the active profile has changed
  tuned-adm verify
  ```

</details>

---

## Task 9 – Investigate SSH Brute-Force Attempts via Journald

Security team is investigating brute-force SSH attempts on bastion-01.

### You must:

- Exact journalctl command(s) only

- Output limited to failed SSH authentication attempts

- Logs from the last 7 full days (excluding today)

- Entries containing both:

    - Failed password

    - authentication failure
  
<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  journalctl -u sshd --since "7 days ago" --until "yesterday" | grep -E "Failed password|authentication failure"
  ```

</details>

---

## Task 10 – Apply Vendor-Recommended Performance Tuning for Java Application

Critical server java-prd-08 experiences high latency during peak load.

**Vendor ticket #INC478912 recommends:**

- Using tuned profile throughput-performance

### You must:

- Apply the tuned profile

- Verify changes are active

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # Identify the currently active tuned profile
  tuned-adm active

  #Change it to the recommended profile: throughput-performance
  tuned-adm profile throughput-performance

  # Ensure the profile becomes active immediately
  tuned-adm active

  # Show proof that the active profile has changed
  tuned-adm verify
  ```

</details>

---

## Task 11 – Recover Business-Critical Services After Power Outage

After a power outage, server fileserver-07 restarted but some services failed.

### You must:

- List all failed systemd units

- Identify units whose name contains:

    - erp

    - storage

    - backup

    - nas
      (case-insensitive)

    - Restart only those matching services

    - Show service status


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # List all failed systemd units
  systemctl list-units --state=failed

  # Identify units whose name contains: erp, storage, backup, nas
  systemctl list-units --type=service --state=failed --no-legend | grep -iE "erp|storage|backup|nas"


  #Restart only those matching services
  for svc in $(systemctl --failed --type=service --no-legend \
  | grep -iE "erp|storage|backup|nas" | cut -d' ' -f1); do
    systemctl restart "$svc"
  done

  # Show service status
  for svc in $(systemctl --failed --type=service --no-legend \
  | grep -iE "erp|storage|backup|nas" | cut -d' ' -f1); do
    systemctl status "$svc"
  done
  ```

</details>

---

## Task 12 – Perform Large, Resumable Backup Transfer Over Unstable Network

You must transfer 182 GB of backup data.

**Details:**

- Source: /backups/full/ on db-prod-04

- Destination: /incoming/db-prod-04/ on dr-storage-01

- You must use a method that:

    - Preserves permissions, ownership, and timestamps

    - Compresses data during transfer

    - Allows resuming if the connection drops
 
    - Shows progress percentage

### You must:

- Show the exact command executed from db-prod-04


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  rsync -avzP /backups/full/  user@dr-storage-01:/incoming/db-prod-04/ 
  ```

</details>

---

## Task 13 – Collect Security-Relevant Journals for a Specific User

SOC is investigating activity under user admin01 on web-prd-11.

- You must provide journalctl command(s) that show, from the current boot only:

- All login events (successful and failed)

- All sudo usage

- All commands executed via sudo

### Requirements:

- Filter results only for user admin01

- Use the most precise filters possible

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # All login events (successful and failed) for admin01 from current boot
  journalctl -b _UID=$(id -u admin01) _SYSTEMD_UNIT=sshd.service -o short-iso


  # All sudo usage (including commands executed) for admin01 from current boot
  journalctl -b _UID=$(id -u admin01) _COMM=sudo -o short-iso
  ```

</details>

---

## Task 14 – Temporarily Enable and Disable Graphical Mode for Application Testing

Server test-gui-03 normally runs headless.

Application team needs temporary GUI access.

### You must:

- Temporarily switch the system to graphical.target

- Do not change the default boot target

- After testing, return the system to multi-user.target

- Again, do not modify the default target

- Show the commands used for both transitions

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  # Temporarily switch the system to graphical.target
  systemctl isolate graphical.target

  # After testing, return the system to multi-user.target
  systemctl isolate multi-user.target
  ```

</details>