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
WORKDIR="/baseline/06_Create_and_Configure_File_Systems_$DIR_DATE"
ARCHIVE="/baseline/06_Create_and_Configure_File_Systems_Server_$DIR_DATE.tar.gz"

# create a directory
mkdir -p "$WORKDIR"

# Baseline Documentation Requirement
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Documentation server1 - Before ======\n"
  echo "\n====== lsblk -f ======\n"
  lsblk -f
  echo "\n====== blkid ======\n"
  blkid /dev/sdb
  echo "\n====== LVM State ======\n"
  vgs
  lvs
  pvs
  echo "\n====== df ======\n"
  df -hT
  echo "\n====== mount ======\n"
  mount
  echo "\n====== /etc/fstab ======\n"
  cat /etc/fstab
  echo "\n====== findmnt ======\n"
  findmnt
  echo "\n====== exportfs ======\n"
  exportfs -v
  
} > "$WORKDIR/baseline_server1-before.txt"


cp /etc/fstab /etc/fstab.bak.$(date +%F_%T)

# 3.4 Centralized NFS Storage (server1)
rpm -q nfs-utils >/dev/null || dnf install nfs-utils -y
systemctl enable --now nfs-server

mkdir -p /exports/homes
mkdir -p /exports/code

chown nobody:nobody /exports/homes
chown nobody:nobody /exports/code

chmod 755 /exports/homes
chmod 755 /exports/code

grep -q "/exports/homes" /etc/exports || echo "/exports/homes  192.168.56.0/24(rw,sync,no_subtree_check)" >> /etc/exports
grep -q "/exports/code" /etc/exports || echo "/exports/code  192.168.56.0/24(rw,sync,no_subtree_check)" >> /etc/exports

exportfs -ra
firewall-cmd --permanent --add-service=nfs
firewall-cmd --reload

showmount -e localhost

# Documentation Requirement
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Documentation server1 - After ======\n"
  echo "\n====== lsblk -f ======\n"
  lsblk -f
  echo "\n====== blkid ======\n"
  blkid /dev/sdb
  echo "\n====== LVM State ======\n"
  vgs
  lvs
  pvs
  echo "\n====== df ======\n"
  df -hT
  echo "\n====== mount ======\n"
  mount
  echo "\n====== /etc/fstab ======\n"
  cat /etc/fstab
  echo "\n====== findmnt ======\n"
  findmnt
  echo "\n====== exportfs ======\n"
  exportfs -v
  
} > "$WORKDIR/baseline_server1-after.txt"


# Archive
tar -czf "$ARCHIVE" -C /baseline "06_Create_and_Configure_File_Systems_Server_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "06 Create and Configure File Systems Server REPORT successfully created at $ARCHIVE"

exit 0