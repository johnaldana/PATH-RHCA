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
WORKDIR="/baseline/10-manage-security_$DIR_DATE"
ARCHIVE="/baseline/10-manage-security_$DIR_DATE.tar.gz"

# Create working directory
mkdir -p "$WORKDIR"

#Phase 0: Initial System
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Initial Firewall ======\n"
  firewall-cmd --get-active-zones
  firewall-cmd --list-all-zones

  echo "\n====== Ports ======\n"
  ss -tlnp
} > "$WORKDIR"/initial_firewall.txt 

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Initial Default Permission ======\n"
  umask
} > "$WORKDIR"/initial_default_permission.txt

cp /etc/ssh/sshd_config "$WORKDIR/sshd_config.bak"

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Initial SELinux ======\n"
  sestatus
  getsebool -a
  ls -Z
  semanage port -l
} > "$WORKDIR"/initial_SELinux.txt

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Initial Services ======\n"
  systemctl list-units --type service
} > "$WORKDIR"/initial_services.txt

systemctl is-active --quiet httpd || systemctl start httpd
systemctl is-active --quiet mariadb || systemctl start mariadb

# Phase 1: Firewall Exposure Review and Remediation
systemctl is-active --quiet firewalld || systemctl start firewalld

firewall-cmd --permanent --get-zones | grep -q company-internal || \
firewall-cmd --permanent --new-zone=company-internal
firewall-cmd --permanent --zone=company-internal --set-target=ACCEPT
firewall-cmd --permanent --zone=company-internal --add-source=192.168.10.0/24
firewall-cmd --reload

firewall-cmd --permanent --zone=public --change-interface=ens160

firewall-cmd --permanent --zone=public --add-port=2222/tcp

firewall-cmd --permanent --zone=public --add-service=http

firewall-cmd --permanent --zone=public --add-service=https

firewall-cmd --permanent --zone=company-internal --add-service=mariadb

firewall-cmd --permanent --zone=public --remove-service=ftp
firewall-cmd --permanent --zone=public --remove-port=21

firewall-cmd --reload

# Phase 2: Default Permission Policy Hardening
grep -q "umask 0027" /etc/profile || echo "umask 0027" >> /etc/profile
grep -q "umask 0027" /etc/bashrc || echo "umask 0027" >> /etc/bashrc

grep -q "umask 0077" /root/.bashrc || echo "umask 0077" >> /root/.bashrc

# Phase 3: SSH Access Lockdown
id sysadmin &> /dev/null || useradd -m -c "Sysadmin" -s /bin/bash  sysadmin 
echo "sysadmin:superstrongpassword_sysadmin!" | chpasswd

ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N ""
sudo -u sysadmin ssh-keygen -t ed25519 -f /home/sysadmin/.ssh/id_ed25519 -N ""

grep -q "$(cat /home/sysadmin/.ssh/id_ed25519.pub)" /home/sysadmin/.ssh/authorized_keys || \
cat /home/sysadmin/.ssh/id_ed25519.pub >> /home/sysadmin/.ssh/authorized_keys
grep -q "$(cat /root/.ssh/id_ed25519.pub)" /root/.ssh/authorized_keys || \
cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys

chown -R sysadmin:sysadmin /home/sysadmin/.ssh
chmod 700 /home/sysadmin/.ssh
chmod 600 /home/sysadmin/.ssh/authorized_keys
chmod 600 /home/sysadmin/.ssh/id_ed25519

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
chmod 600 /root/.ssh/id_ed25519

sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*AllowUsers.*/AllowUsers sysadmin root/' /etc/ssh/sshd_config
sed -i 's/^#*Port.*/Port 2222/' /etc/ssh/sshd_config

sshd -t

semanage port -a -t ssh_port_t -p tcp 2222 || semanage port -m -t ssh_port_t -p tcp 2222
systemctl restart sshd

firewall-cmd --permanent --zone=public --remove-service=ssh
firewall-cmd --permanent --zone=public --remove-port=22

firewall-cmd --reload

grep -q "^Listen 8080" /etc/httpd/conf/httpd.conf || \
echo "Listen 8080" >> /etc/httpd/conf/httpd.conf
systemctl restart httpd

# Phase 4: SELinux Mode Control and Verification
setenforce 0

getenforce > "$WORKDIR/selinux_temp.txt"

setenforce 1

sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config

# Phase 5: SELinux Context Investigation
{
ls -lZ /var/www/html/index.html
ls -lZ /var/www/html/test.html
ls -lZ /etc/ssh/sshd_config

ps auxZ | grep httpd
ps auxZ | grep sshd
} >> "$WORKDIR/phase5_contexts.txt"

# Phase 6: SELinux Context Restoration
touch /root/my_index.html
cp /root/my_index.html /var/www/html/
ls -lZ /var/www/html/my_index.html

restorecon -v /var/www/html/index.html
restorecon -Rv /var/www/html

# Phase 7: SELinux Port Alignment
semanage port -a -t http_port_t -p tcp 8080 || semanage port -m -t http_port_t -p tcp 8080

# Phase 8: SELinux Boolean Configuration

setsebool -P httpd_can_network_connect on
setsebool -P httpd_enable_homedirs on
setsebool -P ftpd_full_access on

# Final Validation
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Final Firewall ======\n"
  firewall-cmd --get-active-zones
  firewall-cmd --list-all-zones

  echo "\n====== Ports ======\n"
  ss -tlnp

  curl http://localhost
  curl http://localhost:8080
} > "$WORKDIR"/final_firewall.txt 


{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Final Default Permission ======\n"
  umask
} > "$WORKDIR"/final_default_permission.txt

cp /etc/ssh/sshd_config "$WORKDIR/sshd_config_final.bak"

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Final SELinux ======\n"
  sestatus
  getsebool -a
  ls -Z
  semanage port -l
} > "$WORKDIR"/final_SELinux.txt


{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Final Services ======\n"
  systemctl list-units --type service
} > "$WORKDIR"/final_services.txt

# Archive
tar -czf "$ARCHIVE" -C /baseline "10-manage-security_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "10 Manage Security REPORT successfully created at $ARCHIVE"

exit 0