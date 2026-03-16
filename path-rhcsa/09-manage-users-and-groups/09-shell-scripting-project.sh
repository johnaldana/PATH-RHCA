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
WORKDIR="/baseline/09-manage-users-and-groups_$DIR_DATE"
ARCHIVE="/baseline/09-manage-users-and-groups_$DIR_DATE.tar.gz"

# Create working directory
mkdir -p "$WORKDIR"

# Phase 0 - Setup
id olddev1 &> /dev/null || useradd -m -c "Former developer who left the company" olddev1 
echo "olddev1:superstrongpassword_olddev1!" | chpasswd
id testadmin &> /dev/null || useradd -m -c "Temporary account used during testing" testadmin
echo "testadmin:superstrongpassword_testadmin!" | chpasswd
id intern2024 &> /dev/null || useradd -m -c "Internship account created last year" intern2024
echo "intern2024:superstrongpassword_intern2024!" | chpasswd

# Phase 1 — Initial System Audit
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Initial System Audit ======\n"
  echo "\n====== Existing user accounts ======\n"
  cut -d: -f1 /etc/passwd
  echo "\n====== Members of the wheel group  ======\n"
  getent group wheel
  echo "\n====== Accounts that may no longer be needed ======\n"
  grep -E "olddev1|testadmin|intern2024" /etc/passwd || true
    
} > "$WORKDIR"/audit_initial.txt

# Phase 2 — Offboarding Former Employees
usermod -L -s /sbin/nologin olddev1
chage -E $(date -d "+7days" +%F) olddev1
gpasswd -d olddev1 wheel 2>/dev/null || true 

usermod -L -s /sbin/nologin testadmin
chage -E $(date -d "+7days" +%F) testadmin
gpasswd -d testadmin wheel 2>/dev/null || true

userdel -r intern2024

# Phase 3 — Configure Password Aging Policy
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 2/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs

# Phase 4 — Onboarding New Employees
id lucia &> /dev/null || useradd -m -c "Frontend Developer" -s /bin/bash  lucia 
echo "lucia:superstrongpassword_lucia!" | chpasswd
passwd -e lucia

id mateo &> /dev/null || useradd -m -c "Backend Developer" -s /bin/bash mateo
echo "mateo:superstrongpassword_mateo!" | chpasswd
passwd -e mateo

id sara &> /dev/null || useradd -m -c "Junior System Administrator" -s /bin/bash sara
echo "sara:superstrongpassword_sara!" | chpasswd
passwd -e sara

id victor &> /dev/null || useradd -m -c "Security Consultant" -s /bin/bash victor
echo "victor:superstrongpassword_victor!" | chpasswd
passwd -e victor

# Phase 5 — Group Administration
getent group developers || groupadd developers
getent group dbadmins || groupadd dbadmins 
getent group deployers || groupadd deployers

usermod -aG developers lucia
usermod -aG developers,dbadmins mateo
usermod -aG developers,deployers sara 

# Phase 6 — Controlled Administrative Access
echo "sara ALL=(ALL) /usr/bin/systemctl status nginx" > /etc/sudoers.d/sara
echo "sara ALL=(ALL) /usr/bin/systemctl restart nginx" >> /etc/sudoers.d/sara
chmod 0440 /etc/sudoers.d/sara
visudo -cf /etc/sudoers.d/sara

echo "victor ALL=(ALL) NOPASSWD: /usr/bin/df" > /etc/sudoers.d/victor
echo "victor ALL=(ALL) NOPASSWD: /usr/bin/du" >> /etc/sudoers.d/victor
echo "victor ALL=(ALL) NOPASSWD: /usr/bin/journalctl" >> /etc/sudoers.d/victor
chmod 0440 /etc/sudoers.d/victor
visudo -cf /etc/sudoers.d/victor

# Phase 7 — Shared Project Directories
mkdir -p /opt/projects/webapp
chown root:developers /opt/projects/webapp
chmod 2770 /opt/projects/webapp

mkdir -p /opt/projects/api
chown root:developers /opt/projects/api
chmod 2770 /opt/projects/api

# Phase 8 — Audit Log Access
getent group auditread || groupadd auditread

gpasswd -a sara auditread
gpasswd -a victor auditread

chown root:auditread /var/log/audit
chmod g+r /var/log/audit/audit.log

# Phase 9 — Final Verification
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Final System Audit ======\n"
  echo "\n====== Existing user accounts ======\n"
  cut -d: -f1 /etc/passwd
  echo "\n====== Members of the wheel group  ======\n"
  getent group wheel
  echo "\n====== Members of the developers group  ======\n"
  getent group developers
  echo "\n====== sudo privileges sara ======\n"
  sudo -l -U sara 
  echo "\n====== sudo privileges victor ======\n"
  sudo -l -U victor 
    
} > "$WORKDIR"/final_audit.txt

# Phase 10 — Documentation
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Documentation ======\n"
  echo "\n====== Accounts Secured ======\n"
  echo "olddev1 testadmin intern2024"
  echo "\n====== Password Policies  ======\n"
  cat /etc/login.defs
  echo "\n====== New Users  ======\n"
  echo  "lucia  Frontend Developer \n"
  echo  "mateo	Backend Developer \n"
  echo  "sara Junior System Administrator\n"
  echo  "victor Security Consultant \n"
  echo "\n====== Access Control* ======\n"
  cat /etc/group
  cat /etc/sudoers.d/*
  ls -ld /opt/projects/webapp
  ls -ld /opt/projects/api
  ls -ld /var/log/audit
    
} > "$WORKDIR"/access_report.md

# Archive
tar -czf "$ARCHIVE" -C /baseline "09-manage-users-and-groups_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "09 Manage Users and Groups REPORT successfully created at $ARCHIVE"

exit 0