#!/bin/bash

# Execution Security
if [[ $EUID -ne 0 ]]; then
   echo "--------------------------------------------------------"
   echo "ERROR: This script requires administrative privileges."
   echo "Please run it using: sudo $0"
   echo "--------------------------------------------------------"
   exit 1
fi

set -euo pipefail

# Working Directory & Packaging Rules
DIR_DATE=$(date +%F) 
WORKDIR="/baseline/07-deploy-configure-and-maintain-systems_$DIR_DATE"
ARCHIVE="/baseline/07-deploy-configure-and-maintain-systems_$DIR_DATE.tar.gz"
LOG_FILE="$WORKDIR/project-log.txt"

# create a directory
mkdir -p "$WORKDIR"
mkdir -p /backup
mkdir -p /localrepo

# Phase 1 – Production Baseline Configuration
hostnamectl set-hostname webprod01.novacart.local

dnf update -y

systemctl enable --now firewalld
firewall-cmd --add-service=http --permanent
firewall-cmd --add-service=https --permanent
firewall-cmd --add-service=ssh --permanent
firewall-cmd --reload

sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
setenforce 1


dnf install -y vim tree bash-completion httpd chrony policycoreutils-python-utils 


# Phase 2 – Repository and Package Management Strategy
subscription-manager status || subscription-manager register --username <user> --password <pass>
subscription-manager attach --auto || true

dnf repolist

dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

dnf install -y createrepo_c dnf-plugins-core
dnf download --resolve --destdir=/localrepo htop ncdu
dnf install -y htop ncdu

createrepo_c /localrepo

cat >  /etc/yum.repos.d/local.repo << 'EOF'
[novacart-local]
name=Local novacart-local
baseurl=file:///localrepo
enabled=1
gpgcheck=0
EOF

dnf clean all

# Phase 3 – Web Server Deployment and Service Management
systemctl enable httpd --now

cat > /var/www/html/index.html << 'EOF'
Welcome to NovaCart Production Server - webprod01
EOF

restorecon -Rv /var/www/html/

curl http://localhost

# Phase 4 – Automation and Scheduled Maintenance

# A. One-Time Emergency Backup (Using at)
systemctl enable --now atd
echo "tar -czf /backup/emergency-web-$(date +%F).tar.gz /var/www/html" | at now + 5 minutes

#tar -tf /backup/emergency-web-$(date +%F).tar.gz 

# B. Recurring Maintenance Task (Using cron)
cat > /usr/local/bin/system-health.sh << 'EOF'
{
  echo "--- Health Check $(date) ---"
  df -h
  free -h
  ps aux --sort=-%mem | head -6
} >> /var/log/system-health.log
EOF

chmod +x /usr/local/bin/system-health.sh 

(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/system-health.sh") | crontab -

# C. Weekly Full Backup (Using cron)
(crontab -l 2>/dev/null; echo "0 3 * * 0 /usr/bin/tar -czf /backup/weekly-full-\$(date +\%F).tar.gz /var/www") | crontab -

# D. Daily Backup Using systemd Timer
cat > /usr/local/bin/backup_var-www-html.sh << 'EOF'
/usr/bin/tar -czf /backup/daily-web-$(date +%F).tar.gz /var/www/html
EOF

chmod +x /usr/local/bin/backup_var-www-html.sh

cat > /etc/systemd/system/backup.service << 'EOF'
[Unit]
Description=Daily Backup Job

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup_var-www-html.sh
EOF

cat > /etc/systemd/system/backup.timer << 'EOF'
[Unit]
Description=Run backup daily at 1 AM

[Timer]
OnCalendar=*-*-* 01:00:00
Persistent=true
Unit=backup.service
RandomizedDelaySec=15m 

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now backup.timer

systemctl list-timers --all
systemctl status backup.timer

# Phase 5 – User and Permission Management
# Groups
getent group webadmin || groupadd webadmin
getent group backupops || groupadd backupops
getent group monitoring || groupadd monitoring

# Users
id deploy &>/dev/null || useradd -G webadmin deploy
id backupuser &>/dev/null || useradd -G backupops backupuser
id monitor1 &>/dev/null || useradd -G monitoring monitor1

chown root:webadmin /var/www
chmod 750 /var/www

chown root:backupops /backup
chmod 770 /backup

setfacl -m g:monitoring:rx /var/www /backup
setfacl -m d:g:monitoring:rx /var/www /backup

# Phase 6 – Time Synchronization Configuration
dnf install -y chrony
systemctl enable --now chronyd

cp /etc/chrony.conf /etc/chrony.conf.bak
  
sed -i 's/^pool/#&/' /etc/chrony.conf
sed -i 's/^server/#&/' /etc/chrony.conf 

echo "server 0.pool.ntp.org iburst" | tee -a /etc/chrony.conf
echo "server 1.pool.ntp.org iburst" | tee -a /etc/chrony.conf

systemctl restart chronyd
systemctl enable chronyd
systemctl status chronyd

chronyc tracking

# Phase 7 – Boot Target Configuration
systemctl get-default
systemctl set-default multi-user.target

# Phase 8 – Bootloader Hardening and Kernel Parameter Management
grubby --update-kernel=ALL --args="quiet splash audit=1"
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub

# GRUB Password Protection
echo "Configuring GRUB password..."
grub2-setpassword

grub2-mkconfig -o /boot/grub2/grub.cfg

# Documentation Requirement
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Documentation - After ======\n"
  echo "\n====== hostnamectl ======\n"
  hostnamectl
  echo "\n====== Status httpd ======\n"
  systemctl status httpd
  echo "\n====== Tasks remain active======\n"
  crontab -l
  echo "\n====== Chronyd ======\n"
  chronyc sources -v
  echo "\n====== SElinux ======\n"
  getenforce
  echo "\n====== firewall ======\n"
  firewall-cmd --list-all
  echo "\n====== Boot target ======\n"
  systemctl get-default
  echo "\n====== Grub ======\n"
  cat /etc/default/grub
  
} > "$LOG_FILE"

# Archive
tar -czf "$ARCHIVE" -C /baseline "07-deploy-configure-and-maintain-systems_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "07 Deploy Configure and Maintain Systems REPORT successfully created at $ARCHIVE"

exit 0