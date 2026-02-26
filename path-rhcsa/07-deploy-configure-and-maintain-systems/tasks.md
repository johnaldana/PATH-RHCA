# 07 - Deploy, Configure, and Maintain Systems - Tasks

These practice scenarios simulate real-world RHEL 9/10 system administration tasks aligned with RHCSA (EX200) objectives.


## Task 1 – One-Time Scheduled Shutdown (at)

A development team requests that the test server shut down exactly 45 minutes from now for scheduled maintenance.

**Activities**

- Ensure the at package is installed and atd service is running.

- Schedule a clean shutdown 45 minutes from now.

- Verify the scheduled job exists.

- Display the job content.

- Cancel the job before it executes.

- Confirm no jobs remain in the queue.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf install at -y
  systemctl enable --now atd

  echo "shutdown -h now" | at now + 45 minutes

  atq
  at -c <ID>
  atrm <ID>
  atq
  ```
</details>

---

## Task 2 – Daily Log Reminder (cron)

User admin must log daily maintenance activity. A cron job should append a timestamped message every day at 04:15 AM.

Message format:

```bash
YYYY-MM-DD Daily log check started
```

**Activities**

- Create a cron job for user `admin`.

- Schedule it to run daily at 04:15.

- Ensure output appends to `/var/log/admin-daily.log`.

- Verify the crontab entry.

- Confirm the file is created if it does not exist.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  id admin || sudo useradd admin

  sudo touch /var/log/admin-daily.log
  sudo chown admin:admin /var/log/admin-daily.log
  sudo chmod 644 /var/log/admin-daily.log

  echo '15 4 * * * echo "$(date +\%F) Daily log check started" >> /var/log/admin-daily.log' | sudo crontab -u admin -

  sudo crontab -u admin -l
  ```

</details>

---

## Task 3 – Weekly Backup for User derek

User derek requires a weekly compressed backup of his home directory every Sunday at 02:00 AM.

Backup format:

```bash
/tmp/derek-home-YYYY-MM-DD.tar.gz
```
**Activities**

- Create script `/home/derek/backup-home.sh`.

- Make the script executable.

- Test it manually.

- Schedule it using derek’s crontab.

- Verify cron entry.

- Confirm ownership and permissions are correct.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

```bash
id derek || useradd derek

cat > /home/derek/backup-home.sh << 'EOF'
#!/bin/bash
tar -czf /tmp/derek-home-$(date +%F).tar.gz /home/derek
EOF
  
chown derek:derek /home/derek/backup-home.sh
chmod 700 /home/derek/backup-home.sh

sudo -u derek /home/derek/backup-home.sh

echo '0 2 * * 0 /home/derek/backup-home.sh' | sudo crontab -u derek -

sudo crontab -u derek -l
```

</details>

---

## Task 4 – System-Wide Cron Job (/etc/cron.d)

A disk health check must run every 30 minutes system-wide as root.

**Activities**

- Create `/usr/local/bin/check-disk.sh` that logs:

    Disk OK

    to `/var/log/disk.log`.

- Make it executable.

- Create `/etc/cron.d/system-health`.

- Configure job to run every 30 minutes as root.

- Verify file syntax and permissions.

- Confirm cron service is active.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

```bash
cat > /usr/local/bin/check-disk.sh << 'EOF'
#!/bin/bash
echo "Disk OK - $(/usr/bin/date)" >> /var/log/disk.log
EOF

chmod 755 /usr/local/bin/check-disk.sh

cat > /etc/cron.d/system-health << 'EOF'
*/30 * * * * root /usr/local/bin/check-disk.sh
EOF

chmod 644 /etc/cron.d/system-health
ls -l /etc/cron.d/system-health
systemctl is-active crond.service

```

</details>

---

## Task 5 – Nightly Cleanup with systemd Timer

Temporary files must be cleaned nightly at 03:00 AM.
The execution must:

    - Be persistent (runs if missed during downtime)

    - Include 10-minute randomized delay

**Activities**

- Create `/usr/local/bin/clean-tmp.sh`.

- Make script executable.

- Create corresponding `.service` file.

- Create `.timer` file using:

    - `OnCalendar=`

    - `Persistent=true`

    - `RandomizedDelaySec=10m`

- Reload systemd.

- Enable and start timer.

- Verify with:
```bash
systemctl list-timers --all
```
<details>
  <summary><b> Show Solution </b></summary>

  **Command**

```bash
cat > /usr/local/bin/clean-tmp.sh << 'EOF'
#!/bin/bash
/usr/bin/rm -rf /tmp/*
EOF

chmod 755 /usr/local/bin/clean-tmp.sh

cat > /etc/systemd/system/clean-tmp.service << 'EOF'
[Unit]
Description=clean tmp

[Service]
Type=oneshot
ExecStart=/usr/local/bin/clean-tmp.sh
EOF

cat > /etc/systemd/system/clean-tmp.timer << 'EOF'
[Unit]
Description=clean tmp timer 

[Timer]
OnCalendar=*-*-* 03:00:00
Persistent=true
Unit=clean-tmp.service
RandomizedDelaySec=600 

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now clean-tmp.timer

systemctl list-timers --all
systemctl status clean-tmp.timer
```

</details>

---

## Task 6 – Health Check Every 2 Hours (systemd Timer Step)

A health check must run every 2 hours (00:00, 02:00, 04:00…).

**Activities**

- Create a script that appends:

    `Health check`

    to `/var/log/health.log`.

- Create service unit.

- Create timer unit using:

    `OnCalendar=*-*-* */2:00:00`

- Enable and start timer.

- Verify next execution time.

- Validate schedule using:
```bash
systemd-analyze calendar
```

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

```bash
cat > /usr/local/bin/health-check.sh << 'EOF'
#!/bin/bash
echo "Health check - $(/usr/bin/date)" >> /var/log/health.log
EOF

chmod 755 /usr/local/bin/health-check.sh

cat > /etc/systemd/system/health-check.service << 'EOF'
[Unit]
Description=Health Check

[Service]
Type=oneshot
ExecStart=/usr/local/bin/health-check.sh
EOF

systemd-analyze calendar '*-*-* */2:00:00'

cat > /etc/systemd/system/health-check.timer << 'EOF'
[Unit]
Description=Health check timer

[Timer]
OnCalendar=*-*-* */2:00:00
Persistent=true
Unit=health-check.service
RandomizedDelaySec=600 

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now health-check.timer

systemctl list-timers --all
systemctl status health-check.timer
```

</details>

---

## Task 7 – Disable Graphical Boot

A production server must always boot in text mode.

**Activities**

- Check current default target.

- Set default to `multi-user.target`.

- Reboot and verify.

- Temporarily switch to `graphical.target` using isolation.

- Confirm default target remains unchanged.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  systemctl get-default 
  systemctl set-default multi-user.target
  shutdown -r
  systemctl isolate graphical.target
  systemctl get-default 
  ```
</details>

---

## Task 8 – Mask and Unmask a Service

The legacy `telnet.socket` must be completely disabled.

**Activities**

- Check service status.

- Mask the service.

- Attempt to start it (confirm failure).

- Unmask the service.

- Start it successfully.

- Verify active state.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  systemctl status telnet.socket
  systemctl mask telnet.socket
  systemctl start telnet.socket
  systemctl unmask telnet.socket
  systemctl start telnet.socket
  systemctl status telnet.socket  
  ```
</details>

---

## Task 9 – Configure chrony for Internal NTP

System must synchronize time using only:

`ntp.company.local`

Public NTP pools must be disabled.

**Activities**

- Edit `/etc/chrony.conf`.

- Remove or comment public pool entries.

- Add internal server with `iburst`.

- Restart `chronyd`.

- Verify with:
```bash
chronyc sources -v
chronyc tracking
```
- Confirm system reports synchronized.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo cp /etc/chrony.conf /etc/chrony.conf.bak
  
  sudo sed -i 's/^pool/#&/' /etc/chrony.conf
  sudo sed -i 's/^server/#&/' /etc/chrony.conf 

  echo "server ntp.company.local iburst" | sudo tee -a /etc/chrony.conf

  sudo systemctl restart chronyd
  sudo systemctl enable chronyd

  chronyc sources -v

  chronyc tracking
  timedatectl status  
  ```
</details>

---

## Task 10 – Set Timezone and Enable NTP

A new VM in London must use the correct timezone and synchronized time.

**Activities**

- Set timezone to:

    `Europe/London`

- Enable NTP using `timedatectl`.

- Confirm:

    - Timezone

    - NTP active

    - System clock synchronized


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  timedatectl set-timezone Europe/London
  timedatectl set-ntp true

  timedatectl status
  ```
</details>

---

## Task 11 – Register and Install Packages from CDN

The system must install vim-enhanced and git from Red Hat CDN.

**Activities**

- Register system using `subscription-manager`.

- Auto-attach subscription.

- Verify enabled repositories.

- Install:

    - vim-enhanced

    - git

- Confirm installation with `rpm -q`.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  subscription-manager register --username <user> --password <pass>
  subscription-manager attach --auto
  sudo subscription-manager status

  dnf repolist

  dnf install -y vim-enhanced git

  rpm -q vim-enhanced
  rpm -q git
  ```
</details>

---

## Task 12 – Create and Use a Local RPM Repository

Create a local repository from RPM files and install a package from it.

**Activities**

- Copy 3–5 RPMs into `/repo/local`.

- Run `createrepo`.

- Create `/etc/yum.repos.d/local.repo`.

- Verify repository availability.

- Install one package from the local repo.

- Confirm installation.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

```bash
mkdir -p /repo/local
cp *.rpm /repo/local

dnf install createrepo_c -y
createrepo /repo/local

cat > /etc/yum.repos.d/local.repo << 'EOF'
[local-repo]
name=Local Repo
baseurl=file:///repo/local
enabled=1
gpgcheck=0
EOF

dnf clean all
dnf repolist

dnf install nombre-paquete --disablerepo="*" --enablerepo="local-repo"

rpm -q nombre-paquete
```
</details>

---

## Task 13 – Mount RHEL ISO as Local Repository

Use RHEL installation ISO as a local software source.

**Activities**

- Mount ISO to `/mnt/iso`.

- Create repo definitions for:

    - BaseOS

    - AppStream

- Clean DNF cache.

- Verify repo listing.

- Install `tree` from local ISO.

- Confirm installation.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

```bash
mkdir -p /mnt/iso

mount -o loop rhel-*.iso /mnt/iso

# Create repo file
cat <<EOF | sudo tee /etc/yum.repos.d/local-iso.repo
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

dnf clean all
dnf repolist

dnf install tree --disablerepo="*" --enablerepo="local-baseos,local-appstream"

rpm -q tree
```
</details>

---

## Task 14 – Permanent GRUB Configuration Change

The system must:

    - Boot silently

    - Use 2-second timeout

**Activities**

- Edit `/etc/default/grub`.

- Set:

    `GRUB_TIMEOUT=2`

- Add:

    `quiet splash`

    to `GRUB_CMDLINE_LINUX`.

- Regenerate grub configuration (BIOS/UEFI).

- Reboot.

- Verify:

    - Timeout change

    - Kernel parameters applied

    - `grub2-editenv list`

## Verification Checklist (Use for All Tasks)

After completing tasks:

- Reboot the system.

- Verify persistence.
  
<details>
  <summary><b> Show Solution </b></summary>

  **Command**

```bash
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2' /etc/default/grub
grubby --update-kernel=ALL --args="quiet splash"

sudo grub2-mkconfig -o /boot/grub2/grub.cfg           # BIOS
sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg  # UEFI

grub2-editenv list

reboot 
```
</details>