#!/bin/bash

# 1. Execution Security
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
WORKDIR="/baseline/05_Local_Storage_Management_$DIR_DATE"
ARCHIVE="/baseline/05_Local_Storage_Management_$DIR_DATE.tar.gz"

# create a directory
mkdir -p "$WORKDIR"


# 2.1 Swap Optimization
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Swap Status ======\n"
  swapon --show
} > "$WORKDIR/swap_status.txt"

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Memory Free ======\n"
  free -h
} > "$WORKDIR/free_memory.txt"

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== /etc/fstab Initial ======\n"
  cat /etc/fstab 
} > "$WORKDIR/fstab_before.txt"

cp /etc/fstab /etc/fstab.bak.$(date +%F_%T)

lsblk -f 

OLD_SWAP_UUID=$(blkid -s UUID -o value /dev/sdb1)

swapoff /dev/sdb1

parted /dev/sdb rm 1
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary 1MiB 20GiB
parted /dev/sdb set 1 lvm on

parted /dev/sdc mklabel gpt
parted /dev/sdc mkpart primary 1MiB 60GiB
parted /dev/sdc set 1 lvm on

partprobe 
udevadm settle

pvcreate /dev/sdb1
pvcreate /dev/sdc1
vgextend vg_db /dev/sdb1 /dev/sdc1

lvcreate -n lv_swap -L 36GiB vg_db

mkswap /dev/vg_db/lv_swap

SWAP_UUID=$(blkid -s UUID -o value /dev/vg_db/lv_swap)
echo "UUID=$SWAP_UUID swap swap defaults 0 0" >> /etc/fstab

sed -i "s/UUID=$OLD_SWAP_UUID swap swap defaults 0 0/#&/" /etc/fstab

swapon -a

# 2.2 Database Storage Expansion
lvextend -r -L +30G /dev/vg_db/lv_mysql

# 2.3 Utility Storage for Logs and Backups
lvcreate -n lv_logs -L 20GiB vg_db
mkfs.xfs -L DB_LOGS_2026 /dev/vg_db/lv_logs

mkdir -p /var/log/db_backups

echo "LABEL=DB_LOGS_2026 /var/log/db_backups xfs defaults 0 0" >> /etc/fstab

mount -a 

# 4. Evidence Management Guidelines
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo -e "===== LV Status ======\n"
  lvdisplay
} > "$WORKDIR/lv_status.txt"

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo -e "===== VG Status ======\n"
  vgdisplay
} > "$WORKDIR/vg_status.txt" 

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo -e "===== Filesystem Usage ======\n"
  df -h 
} > "$WORKDIR/mysql_df.txt"


{
  echo -e "====== Timestamp: $(date) ======\n"
  echo -e "===== Disk/partition info ======\n"
  lsblk -f
} > "$WORKDIR/lsblk.txt"

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo -e "===== Disk/partition info  ======\n"
  blkid
} > "$WORKDIR/blkid.txt" 

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== /etc/fstab After ======\n"
  cat /etc/fstab 
} > "$WORKDIR/fstab_after.txt"

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Last Logs======\n"
  journalctl -n 100 --no-pager
} > "$WORKDIR/logs.txt"

{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Final Verification======\n"
  lsblk -f
  swapon --show
  findmnt --verify 
} > "$WORKDIR/final_verification.txt" 


# Archive
tar -czf "$ARCHIVE" -C /baseline "05_Local_Storage_Management_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "05_Local_Storage_Management REPORT successfully created at $ARCHIVE"

exit 0