# 06-Create and Configure File Systems - Guide

**Official objectives (RHEL 9 / RHCSA EX200):**
- Create, mount, unmount, and use **vfat**, **ext4**, and **xfs** file systems
- Mount and unmount network file systems using **NFS**
- Configure **autofs**
- Extend existing logical volumes
- Create and configure **set-GID directories** for collaboration (often tested with permissions)
- Diagnose and correct file permission problems

---

## 6.1. Create, mount, unmount, and use vfat, ext4, and xfs file systems

### Preparation (example disks: /dev/sdb, /dev/sdc)

```bash
# List available block devices
lsblk

# Create a new partition with gdisk (n -> default -> default -> +2G -> 8300 -> w)
gdisk /dev/sdb

# Alternative with parted
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary 1MiB 2GiB

partprobe 
udevadm settle
```
### Create file systems

```bash
# XFS (Default in RHEL. Cannot be shrunk, only grown.)
mkfs.xfs -f /dev/sdb1

# ext4
mkfs.ext4 /dev/sdc1

# vfat (FAT32 – good for USB/cross-OS sharing)
mkfs.vfat -F 32 /dev/sdd1
# or shorthand
mkfs.vfat /dev/sdd1
```

### Manual mount / unmount

```bash
mkdir /mnt/xfs /mnt/ext4 /mnt/vfat

mount /dev/sdb1 /mnt/xfs
mount /dev/sdc1 /mnt/ext4
mount /dev/sdd1 /mnt/vfat

# Verify mounts
mount | grep mnt
findmnt -t xfs,ext4,vfat

# Test write
touch /mnt/xfs/testfile.txt
ls -l /mnt/xfs

# Unmount (use -l for lazy unmount if busy)
umount /mnt/xfs
umount -l /mnt/ext4
```

### Persistent mounting using UUID (recommended – safer than device names)bash

```bash
# Get UUIDs
blkid /dev/sdb1
# Example output: /dev/sdb1: UUID="abcd1234-..." TYPE="xfs"

# Edit /etc/fstab (always backup first: cp /etc/fstab /etc/fstab.bak)
vim /etc/fstab

# Add lines (use UUID, not /dev/sdX)
UUID=abcd1234-...     /mnt/xfs    xfs     defaults        0 0
UUID=efgh5678-...     /mnt/ext4   ext4    defaults        0 2
UUID=ijkl9012-...     /mnt/vfat   vfat    defaults,uid=1000,gid=1000,umask=002    0 0

# Test without reboot
mount -a
```

---

## 6.2. Mount and unmount network file systems using NFS

**Quick NFS server setup (on server.example.com)**

```bash
dnf install nfs-utils -y
systemctl enable --now nfs-server

mkdir /nfsexport
chown nobody:nobody /nfsexport
chmod 755 /nfsexport          # or adjust as needed

# /etc/exports
echo "/nfsexport  192.168.5.0/24(rw,sync,no_subtree_check)" >> /etc/exports

exportfs -ra
firewall-cmd --permanent --add-service=nfs
firewall-cmd --reload

showmount -e localhost
```
**root_squash (default behavior)**

- Maps remote root to nobody on the server.

- Protects the server from client root users.

- Do not use no_root_squash in production unless necessary.

**NFS client side**

```bash
dnf install nfs-utils -y

mkdir /mnt/nfs_share

# Manual mount
mount -t nfs server.example.com:/nfsexport /mnt/nfs_share
# or by IP
mount 192.168.5.10:/nfsexport /mnt/nfs_share

# Verify
mount | grep nfs
df -h | grep nfs

# Unmount
umount /mnt/nfs_share

# Persistent in /etc/fstab
server.example.com:/nfsexport    /mnt/nfs_share    nfs    defaults,_netdev,nfsvers=4,soft,timeo=10    0 0
```
**NFS relies on numeric UID/GID, not usernames.**

    - Clients with same username but different UID → treated as different users.
    - Two clients with same UID → same permissions.
---

## 6.3. Configure autofs (on-demand mounting)

```bash
dnf install autofs -y

# Basic example: auto-mount NFS home directories under /home
vim /etc/auto.master
# Add or edit line:
/home    /etc/auto.home    --timeout=60

vim /etc/auto.home
# Format:  key    options                          location
*        -fstype=nfs4,rw,soft            nfsserver.example.com:/home/&

# Start and enable
systemctl enable --now autofs

# Test (should mount automatically on access)
ls /home/bob
cd /home/bob
```
**Another common example (project directory):**

```bash
# /etc/auto.master
/project    /etc/auto.project

# /etc/auto.project
data    -fstype=nfs4    nfsserver:/export/data
```
---

## 6.4. Extend existing logical volumes (LVM)

```bash
# Check current status
vgs
lvs
df -h /home

# Option 1: Extend using free space in VG
lvextend -r -L +10G /dev/mapper/rhel-home
# or use all free space
lvextend -r -l +100%FREE /dev/mapper/rhel-home

# Grow the filesystem (online)
# For XFS:
xfs_growfs /home

# For ext4:
resize2fs /dev/mapper/rhel-home

# Verify
df -h /home

#If you need to add a new PV
pvcreate /dev/sdc
vgextend rhel /dev/sdc
```

---


## 6.5. Diagnose and correct file permission problems + set-GID directories

```bash
ls -ld /directory
getfacl /file-or-dir           # if ACLs are in use
namei -l /long/path/to/file    # shows permissions on every level
```

**Set-GID for collaboration (files inherit group)**

```bash
mkdir /shared-project
chgrp developers /shared-project
chmod 2775 /shared-project          # 2 = set-GID bit

ls -ld /shared-project
# Should show: drwxrwsr-x   (s in group position)

chmod 1777 /temp                 # rwxrwxrwt (sticky bit – only owner can delete)
setfacl -m u:bob:rwx /file       # ACL example
```
