# 05 – Local Storage Management - Tasks
**RHCSA – RHEL 9**

## Tasks 1: Emergency Swap Activation During Memory Pressure

Monitoring alerts indicate critically low available memory during peak hours. The system is experiencing performance degradation.

**Objectives**

- Create a new 2 GiB logical volume named lv_swap2 in existing VG vg_data.

- Format it as swap.

- Activate it immediately.

- Configure persistent activation using UUID in /etc/fstab.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  lvcreate -n lv_swap2 -L 2G vg_data
  mkswap /dev/vg_data/lv_swap2
  swapon /dev/vg_data/lv_swap2
  blkid /dev/vg_data/lv_swap2

  vi /etc/fstab

  UUID=<uuid> swap swap defaults 0 0 
  
  swapon --show
  free -h
  ```
 
</details>

---


## Tasks 2: Expand Application Storage Without Downtime

The web application mounted at /var/www (device: /dev/vg_web/lv_www) is running out of disk space. Downtime is not allowed.

**Objectives**

- Ensure PV /dev/sdc1 belongs to vg_web (add if needed).

- Extend lv_www by 10 GiB.

- Grow the XFS filesystem online.

- Ensure application remains mounted.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  pvs
  vgextend vg_web /dev/sdc1
  vgs
  lvextend -r -L +10G /dev/vg_web/lv_www

  df -h /var/www
  lvs vg_web/lv_www
  ```
</details>


---


## Taks 3: Create Dedicated Backup Volume with Label

Nightly backups require a dedicated storage area.

**Objectives**

- Create a 15 GiB LV lv_backup in vg_storage.

- Format with XFS.

- Set filesystem label to BACKUPS_2026.

- Mount temporarily at /mnt/backup.

- Configure persistent mount in /etc/fstab using LABEL (not UUID or device path).


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  vgs vg_storage
  lvcreate -n lv_backup -L 15G vg_storage
  lvs
  mkfs.xfs -L BACKUPS_2026 /dev/vg_storage/lv_backup
  
  mkdir -p /mnt/backup
  mount /dev/vg_storage/lv_backup /mnt/backup
  
  vi /etc/fstab
  LABEL=BACKUPS_2026 /mnt/backup xfs defaults 0 0 
  
  umount /mnt/backup

  mount -a
  df -h /mnt/backup
  lsblk -f 
  ```
</details>

---


## Tasks 4: Safe Removal of Unused Logical Volume

Old logical volume lv_olddata in vg_data is no longer needed.

**Objectives**

- Ensure it is unmounted.

- Confirm no processes are using it.

- Remove the LV safely.

- Verify free PE count increases in VG.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  lsblk
  umount /dev/vg_data/lv_olddata

  lsof /dev/vg_data/lv_olddata
  grep lv_olddata /etc/fstab

  lvremove -y /dev/vg_data/lv_olddata
    
  vgdisplay vg_data
  lvs 
  ```
</details>

---

## Tasks 5: Build Complete LVM Stack from New Disk

A new disk /dev/sdd was added for database storage.

**Objectives**

- Create GPT partition table.

- Create one 40 GiB partition (type 8e00).

- Initialize as PV.

- Create VG vg_db.

- Create LV lv_mysql using 100% free space.

- Format with ext4.

- Do not mount.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  parted /dev/sdd mklabel gpt

  parted /dev/sdd mkpart primary 1MiB 40.1GiB
  parted /dev/sdd set 1 lvm on

  partprobe

  pvcreate /dev/sdd1
  pvs

  vgcreate vg_db /dev/sdd1
  vgs

  lvcreate -n lv_mysql -l 100%FREE vg_db

  mkfs.ext4 /dev/vg_db/lv_mysql  
  ```
</details>

---

## Tasks 6: Add Swap Partition Non-Destructively

System has no swap and OOM killer events are occurring.

**Objectives**

- Create 4 GiB GPT partition on /dev/sdb (type 8200).

- Format as swap.

- Activate immediately.

- Add persistent entry using UUID.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  lsblk
  parted /dev/sdb print

  # If needed:
  parted /dev/sdb mklabel gpt

  parted /dev/sdb mkpart primary 1MiB 4.1GiB
  parted /dev/sdb set 1 swap on

  partprobe

  mkswap /dev/sdb1
  swapon /dev/sdb1

  blkid /dev/sdb1
  vi /etc/fstab
  UUID=<uuid> swap swap defaults 0 0 
  swapon -a    
  ```
</details>

---


## Tasks 7:  Migrate Data Off Failing Physical Volume

/dev/sdc1 in vg_data shows SMART errors and must be removed without downtime.

**Objectives**

- Move all data using pvmove.

- Remove PV from VG using vgreduce.

- Remove PV metadata with pvremove.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  vgdisplay vg_data 

  pvmove /dev/sdc1

  vgreduce vg_data /dev/sdc1

  pvremove /dev/sdc1 

  pvs   
  ```
</details>


---


## Tasks 8: Create Utility Logical Volume Using Specific Extents

Application logs need isolated storage.

**Objectives**

- Create LV lv_logs (5 GiB) in vg_data.

- Use exactly 1200 physical extents (-l 1200).

- Format with XFS.

- Mount at /var/log/extra.

- Configure persistent mount using UUID.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  vgdisplay vg_data | grep "PE Size"

  lvcreate -n lv_logs -l 1200 vg_data

  lvdisplay /dev/vg_data/lv_logs

  mkfs.xfs /dev/vg_data/lv_logs

  blkid /dev/vg_data/lv_logs

  mkdir -p /var/log/extra

  mount /dev/vg_data/lv_logs /var/log/extra

  df -h /var/log/extra

  vi /etc/fstab 

  UUID=<uuid> /var/log/extra xfs defaults 0 0

  umount /var/log/extra

  mount -a  
  ```
</details>

---

## Tasks 9: Extend LV Using Percentage of Free Space

Monitoring volume lv_monitor is nearly full.

**Objectives**

- Extend it to use 80% of current free space in vg_monitor.

- Resize ext4 filesystem.

- Ensure service remains operational.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  vgdisplay vg_monitor

  lvextend -r -l 80%FREE /dev/vg_monitor/lv_monitor
  
  df -h
  lvs
  ```
</details>

---

## Tasks 10: Setup Collaboration Storage

Team requires shared storage at /share.

**Objectives**

- Create 8 GiB LV lv_share in vg_data.

- Format XFS.

- Mount at /share.

- Enable set-GID bit for group collaboration.

- Configure persistent mount via UUID.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  vgdisplay vg_data
  lvcreate -n lv_share -L 8G vg_data
  lvs

  mkfs.xfs /dev/vg_data/lv_share
  mkdir /share
  
  mount /dev/vg_data/lv_share /share
  chown root:team /share
  chmod 2775 /share

  blkid /dev/vg_data/lv_share
  vi /etc/fstab
  UUID=<uuid> /share xfs defaults 0 0

  umount /share
  mount -a

  ls -ld /share
  df -h
  ```
</details>

---

## Tasks 11: Replace Old Partition with LVM-Based Storage

Direct partition /dev/sdb1 (mounted at /data) is too small.

**Objectives**

- Create new GPT partition on /dev/sdc.

- Create PV → VG vg_newdata → LV lv_data (50 GiB).

- Format with XFS.

- Copy existing data from /data.

- Update /etc/fstab to use new UUID.

- Unmount and remove old partition.
  

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  lsblk
  parted /dev/sdc mklabel gpt

  parted /dev/sdc mkpart primary 1MiB 50.1GiB
  parted /dev/sdc set 1 lvm on

  partprobe

  pvcreate /dev/sdc1
  pvs
  vgcreate vg_newdata /dev/sdc1
  vgs
  lvcreate -n lv_data -L 50G vg_newdata
  lvs
  
  mkfs.xfs /dev/vg_newdata/lv_data
  mkdir /newdata
  mount /dev/vg_newdata/lv_data /newdata

  cp -av /data/. /newdata/ 
  
  umount /newdata
  umount /data

  blkid /dev/vg_newdata/lv_data
  
  vi /etc/fstab
  UUID=<uuid> /data xfs defaults 0 0 
  
  mount -a
  df -h /data
  
  parted /dev/sdb rm 1
  lsblk
  ```
</details>

---

## Tasks 12: Persistent Mount After Disk Reordering

Disk names changed after hardware reordering (/dev/sdb became /dev/sdc).

**Objectives**

- Ensure /backup mount uses UUID.

- Update /etc/fstab if necessary.

- Test configuration safely.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  lsblk -f
  umount /backup
  blkid /dev/sdc1
  vi /etc/fstab
  UUID=<uuid> /backup xfs defaults 0 0 
  mount -a
  ```
</details>

---


## Tasks 13: Add Swap File as Quick Fallback

No free disk space for new LV or partition.

**Objectives**

- Create 1 GiB swap file /swapfile1.

- Set correct permissions.

- Activate it.

- Add persistent entry in /etc/fstab.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  fallocate -l 1G /swapfile1
  chmod 600 /swapfile1
  mkswap /swapfile1
  swapon /swapfile1

  echo "/swapfile1 none swap defaults 0 0" >> /etc/fstab
 
  swapon --show  
  ```
</details>

---


## Tasks 14: Full Production Storage Expansion Workflow

Application storage growth required without downtime.

**Objectives**

- Create new partition /dev/sdd2.

- Initialize as PV.

- Extend VG vg_app.

- Extend LV lv_appdata by +15 GiB.

- Grow XFS filesystem online.

- Confirm mount uses UUID.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  lsblk -f

  parted /dev/sdd mkpart primary 1MiB 15.1GiB  
  parted /dev/sdd set 2 lvm on

  partprobe

  pvcreate /dev/sdd2
  pvs
  vgextend vg_app /dev/sdd2
  vgs
  lvextend -r -L +15G /dev/vg_app/lv_appdata

  grep lv_appdata /etc/fstab
  ```
</details>
