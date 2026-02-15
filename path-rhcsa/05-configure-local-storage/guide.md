# 05-Local Storage Management - Guide  

This section covers partitioning, LVM, and filesystem management, including non-destructive operations.

Objective: Configure local storage.

Skills covered:
- GPT partitioning
- LVM lifecycle
- Persistent mounting with UUID/LABEL
- Filesystem resizing
- Swap configuration
- Non-destructive storage extension

---

## 5.1. List Partitions on GPT Disks

GPT (GUID Partition Table) is the standard for modern systems. While fdisk now supports GPT, gdisk is specifically designed for it. Modern RHEL systems use GPT by default for disks >2 TiB or UEFI systems.

Note: RHCSA objectives include both MBR and GPT. Use fdisk for MBR disks (legacy <2TiB BIOS systems); gdisk/parted for GPT (default in RHEL 10).

**List partitions (all tools):**

```bash
lsblk -f
fdisk -l
gdisk -l /dev/sdX          # GPT-specific
parted -l
```
---

## 5.2. Create and Delete Partitions (GPT)

Use gdisk (recommended for GPT) or parted.Using gdisk (interactive, similar to fdisk):

```bash
gdisk /dev/sdb
```

**Inside gdisk:**

- o → create a new empty GPT partition table (careful — wipes existing!)
- n → new partition (accept defaults for full disk or specify start/end sectors)Partition number (default 1)
  - First sector (default)
  - Last sector or +size (e.g. +2G)
  - Hex code or GUID: 8e00 for Linux LVM (most common in RHCSA), or leave blank for default Linux filesystem
- p → print current table
- d → delete partition (enter number)
- w → write changes (commit)
- q → quit without saving

**Using parted** (scriptable / non-interactive friendly):

```bash
# Set GPT label (Only if disk is new)
parted /dev/sdb mklabel gpt

# Create partition (e.g. 2 GiB LVM type)
parted /dev/sdb mkpart primary 1MiB 2GiB
parted /dev/sdb set 1 lvm on

# Delete partition 1
parted /dev/sdb rm 1

# Print
parted /dev/sdb print
```

After partitioning → partprobe or udevadm settle to update kernel if needed.

**Tips:**

Use MiB/GiB for precise sizing.

Always check with lsblk after changes.

---

## 5.3. Create and remove physical volumes (PVs)

```bash
# Initialize partition/disk as PV (wipes any existing filesystem!)
pvcreate /dev/sdb1
pvcreate /dev/sdc             

# List PVs
pvs
pvdisplay /dev/sdb1

# Remove PV (only if not used in any VG)
pvremove /dev/sdb1
```

---

## 5.4. Assign physical volumes to volume groups (VGs)

```bash
# Create new VG
vgcreate vg_data /dev/sdb1 /dev/sdc1

# Or extend existing VG
vgextend vg_data /dev/sdd1

# List
vgs
vgdisplay vg_data

# Remove PV from VG (must be empty)
vgreduce vg_data /dev/sdd1

#pvmove first if data exists
pvmove /dev/sdd1
vgreduce vg_data /dev/sdd1

# Delete VG (all LVs must be removed first!)
vgremove vg_data
```

---

## 5.5. Create and Delete Logical Volumes (LVs)

```bash
# Create LV (examples)
lvcreate -n lv_web -L 5G   vg_data                      # 5 GiB
lvcreate -n lv_logs -l 100%FREE vg_data                 # all remaining space
lvcreate -n lv_db -l 500 vg_storage                     # Use exactly 500 physical extents
lvextend -L +10G /dev/vg_data/lv_db                     # extend by 10 GiB (if space)

# List
lvs
lvdisplay /dev/vg_data/lv_web

# Delete LV (careful — irreversible!)
lvremove /dev/vg_data/lv_web
# or: lvremove vg_data/lv_web
```

---


## 5.6. Format and Mount Filesystems

```bash
mkfs.xfs /dev/vg_data/lv_web                # Create Filesystem xfs
mount /dev/vg_data/lv_web /mnt              # Mount Temporarily
```

Best practice: always use UUID or LABEL in /etc/fstab — device names (/dev/sda1) can change on reboot.

**Get UUID / LABEL:**

```bash
blkid
lsblk -f
blkid /dev/mapper/vg_data-lv_web
```

**Mount at Boot by UUID**

```bash
blkid /dev/vg_data/lv_web
```

**Output example:**

```bash
/dev/vg_data/lv_web: UUID="a1b2c3d4-e5f6-7890-abcd-ef1234567890" TYPE="xfs"
```

**Add to /etc/fstab:**

```bash
UUID=a1b2c3d4-e5f6-7890-abcd-ef1234567890  /mnt  xfs  defaults  0 0
```

**Or mount by label:**

**Set LABEL (if needed):**

```bash
# ext4
e2label /dev/mapper/vg_data-lv_web backup_data

# xfs
xfs_admin -L backup_data /dev/mapper/vg_data-lv_web
```

**Then in /etc/fstab:**

```bash
LABEL=backup_data  /mnt  xfs  defaults  0 0
```

**Test fstab before reboot:**

```bash
mount -a               # mounts everything in fstab — fix errors before reboot!
```

---


## 5.7. Non-Destructive Operations

Add new partition: use parted or gdisk carefully; avoid deleting existing partitions.

```bash
gdisk /dev/sdb
# n → create new partition in free space
# t → 8e00 (LVM)
# w

partprobe /dev/sdb
pvcreate /dev/sdb2
vgextend vg_data /dev/sdb2
lvextend -L +15G -r /dev/vg_data/lv_web         # -r resizes filesystem (xfs/ext4)

# For XFS:
# Filesystem must be mounted to grow
# Shrinking is NOT supported
# XFS cannot be reduced. 

xfs_growfs /mountpoint

# For ext4:

resize2fs /dev/vg_data/lv_web                    #To shrink ext4, filesystem must be unmounted.
```

## Add new LV non-destructively:bash

```bash
lvcreate -n lv_new -L 8G vg_data
mkfs.xfs /dev/vg_data/lv_new
mkdir /mnt/new
mount /dev/vg_data/lv_new /mnt/new

# Get UUID → add to /etc/fstab
blkid /dev/vg_data/lv_new
```

---

## 5.8. Swap:

Swap is "emergency RAM" on your disk.

**Step-by-Step: Adding LVM Swap Space**

```Bash

# 1. Create the Logical Volume (LV) 
# -n: name, -L: size, followed by the Volume Group name
lvcreate -n lv_swap -L 512M vg_data

# 2. Format the LV as swap space
mkswap /dev/vg_data/lv_swap

# 3. Retrieve the UUID for persistent mounting
blkid /dev/vg_data/lv_swap

# 4. Configure persistent mounting in /etc/fstab
UUID=xxxx-xxxx  none  swap  defaults  0 0

# 5. Activate all swap devices defined in /etc/fstab
swapon -a

# 6. Verify that the swap is active and check its priority/size
swapon --show
```

**Swap File**

```bash
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
swapon --show
```

**Verify everything:**

```bash
lsblk
df -h
swapon -s
```