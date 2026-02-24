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
ARCHIVE="/baseline/06_Create_and_Configure_File_Systems_$DIR_DATE.tar.gz"

# create a directory
mkdir -p "$WORKDIR"

# Groups
getent group developers || groupadd developers
getent group finance || groupadd finance
getent group ops || groupadd ops

# Users
id dev1 &>/dev/null || useradd -G developers dev1
id dev2 &>/dev/null || useradd -G developers dev2
id fin1 &>/dev/null || useradd -G finance fin1
id auditor &>/dev/null || useradd auditor
id bob &>/dev/null || useradd -G ops bob

# Baseline Documentation Requirement
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Documentation client1 - Before ======\n"
  echo "\n====== lsblk ======\n"
  lsblk /dev/sdb &>/dev/null || { echo "Disk /dev/sdb not found"; exit 1; }
  lsblk /dev/sdc &>/dev/null || { echo "Disk /dev/sdc not found"; exit 1; }
  lsblk /dev/sdd &>/dev/null || { echo "Disk /dev/sdd not found"; exit 1; }
  echo "\n====== blkid ======\n"
  blkid /dev/sdb
  blkid /dev/sdc
  blkid /dev/sdd 
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
} > "$WORKDIR/baseline_client1-before.txt"

cp /etc/fstab /etc/fstab.bak.$(date +%F_%T)

for disk in /dev/sdb /dev/sdc /dev/sdd; do
    [[ -b $disk ]] || { echo "ERROR: $disk not found"; exit 1; }
    
    if lsblk -no FSTYPE "$disk" | grep -q .; then
      echo "ERROR: $disk already contains a filesystem"
      exit 1
    fi

    if pvs | grep -q "$disk"; then
      echo "ERROR: $disk is already part of an LVM Physical Volume"
      exit 1
    fi
done

# 3.1 Developer High-Performance Scratch Space
parted -s /dev/sdb print | grep -q "gpt" || parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary 1MiB 2.1GiB
parted -s /dev/sdb set 1 lvm on

partprobe 
udevadm settle


pvcreate /dev/sdb1
vgdisplay vg_scratch > /dev/null 2>&1 || vgcreate vg_scratch /dev/sdb1
lvdisplay lv_scratch > /dev/null 2>&1 || lvcreate -n lv_scratch -L 2G vg_scratch

blkid /dev/vg_scratch/lv_scratch >/dev/null 2>&1 || mkfs.xfs /dev/vg_scratch/lv_scratch
mkdir -p /scratch
mount /dev/vg_scratch/lv_scratch /scratch

lv_scratch_UUID=$(blkid -s UUID -o value /dev/vg_scratch/lv_scratch)
grep -q "/scratch" /etc/fstab || \
echo "UUID=$lv_scratch_UUID /scratch xfs defaults,noatime 0 0" >> /etc/fstab

umount /scratch

# 3.2 Operational Data Volume (ext4)
parted -s /dev/sdc print | grep -q "gpt" || parted -s /dev/sdc mklabel gpt
parted -s /dev/sdc mkpart primary 1MiB 3.1GiB

partprobe 
udevadm settle

blkid /dev/sdc1 >/dev/null 2>&1 || mkfs.ext4 /dev/sdc1
mkdir -p /team
mount /dev/sdc1 /team

sdc1_UUID=$(blkid -s UUID -o value /dev/sdc1)
grep -q "/team" /etc/fstab || \
echo "UUID=$sdc1_UUID /team ext4 defaults 0 2" >> /etc/fstab

umount /team

lsblk -f 

# 3.3 Cross-Platform Share (vfat / FAT32)
parted -s /dev/sdd print | grep -q "gpt" || parted -s /dev/sdd mklabel gpt
parted -s /dev/sdd mkpart primary 1MiB 1.1GiB

partprobe
udevadm settle

blkid /dev/sdd1 >/dev/null 2>&1 || mkfs.vfat /dev/sdd1
mkdir -p /usbshare
mount /dev/sdd1 /usbshare

sdd1_UUID=$(blkid -s UUID -o value /dev/sdd1)
gid=$(getent group developers | cut -d: -f3)
grep -q "/usbshare" /etc/fstab || \
echo "UUID=$sdd1_UUID /usbshare vfat defaults,gid=$gid,umask=002 0 0" >> /etc/fstab

umount /usbshare

mount -a

# 3.5 NFS Client Configuration
rpm -q autofs >/dev/null || dnf install autofs -y

showmount -e 192.168.56.10 || echo "Warning: NFS server not reachable"

mkdir -p /mnt/homes
mkdir -p /mnt/code

mount -t nfs4 192.168.56.10:/exports/homes /mnt/homes
mount -t nfs4 192.168.56.10:/exports/code  /mnt/code

findmnt | grep nfs

umount /mnt/homes
umount /mnt/code

mkdir -p /code

grep -q "/code" /etc/fstab || \
echo "192.168.56.10:/exports/code  /code  nfs4  defaults,_netdev,soft,intr  0  0" >> /etc/fstab

mount -a
findmnt /code

mkdir -p /homes

echo "*  -fstype=nfs4,hard  192.168.56.10:/exports/homes/&" > /etc/auto.homes
grep -q "^/homes" /etc/auto.master || \
echo "/homes    /etc/auto.homes    --timeout=60" >> /etc/auto.master

systemctl enable --now autofs

findmnt /code
systemctl status autofs
ls /homes/dev1 || echo "Autofs mount test failed"

# 3.6 Collaborative Development Directory (set-GID)
mkdir -p /opt/team-repo
chown :developers /opt/team-repo
chmod 2775 /opt/team-repo

# 3.7 Public Drop Directory (Sticky Bit)
mkdir -p /public/drop
chmod 1777 /public/drop

# 3.8 Finance Sensitive Reports (ACL Implementation)
mkdir -p /opt/finance-reports
chown :finance /opt/finance-reports
chmod 770 /opt/finance-reports

command -v setfacl >/dev/null || dnf install acl -y

setfacl -m u:auditor:rx /opt/finance-reports
setfacl -m d:u:auditor:rX /opt/finance-reports
getfacl /opt/finance-reports

# 3.9 Online LVM Extension
lvextend -r -L +1G /dev/vg_scratch/lv_scratch || echo "WARNING: lvextend failed, skipping."

# Documentation Requirement
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Documentation client1 - After ======\n"
  echo "\n====== lsblk -f ======\n"
  lsblk -f
  echo "\n====== blkid ======\n"
  blkid /dev/sdb
  blkid /dev/sdc
  blkid /dev/sdd 
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
  getfacl /opt/finance-reports
  
} > "$WORKDIR/baseline_client1-after.txt"

# Archive
tar -czf "$ARCHIVE" -C /baseline "06_Create_and_Configure_File_Systems_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "06 Create and Configure File Systems REPORT successfully created at $ARCHIVE"

exit 0