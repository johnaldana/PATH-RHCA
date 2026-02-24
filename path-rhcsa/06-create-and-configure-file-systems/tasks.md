# 06 – Create and Configure File Systems - Tasks
**RHCSA – RHEL 9**

## Tasks 1: Create and Persistently Mount XFS Filesystem

A new disk /dev/sdb has been added to the system. It must be prepared for application data storage using XFS.

### You must:

- Create a GPT partition of 500 MiB on /dev/sdb.

- Format it as XFS.

- Mount it at /xfsdata.

- Configure persistent mounting using UUID in /etc/fstab.

- Verify using df -h and mount | grep xfs.
  
<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  parted /dev/sdb mklabel gpt
  parted /dev/sdb mkpart primary 1MiB 501MiB

  partprobe
  udevadm settle

  mkfs.xfs /dev/sdb1

  mkdir /xfsdata

  mount /dev/sdb1 /xfsdata

  echo "UUID=$(blkid /dev/sdb1 -s UUID -o value) /xfsdata xfs defaults 0 0" >> /etc/fstab

  umount /xfsdata
  mount -a

  df -h
  mount | grep xfs  
  findmnt /xfsdata
  ```
</details>

---

## Tasks 2: Create and Persistently Mount ext4 Filesystem

The system administrator needs an ext4 filesystem for web content storage.

### You must:

- Create a 300 MiB partition on /dev/sdc.

- Format it as ext4.

- Mount it at /ext4data.

- Configure persistence using UUID.

- Set dump/fsck order to 0 2 in /etc/fstab.

- Test using mount -a.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  parted /dev/sdc mklabel gpt
  parted /dev/sdc mkpart primary 1MiB 301MiB

  partprobe
  udevadm settle

  mkfs.ext4 /dev/sdc1

  mkdir /ext4data

  mount /dev/sdc1 /ext4data

  echo "UUID=$(blkid /dev/sdc1 -s UUID -o value) /ext4data ext4 defaults 0 2" >> /etc/fstab

  umount /ext4data
  mount -a

  df -h
  mount | grep ext4  
  ```
</details>

---

## Task 3: Create VFAT (FAT32) Filesystem for USB-like Use

A removable disk must be prepared for cross-platform compatibility.

### You must:

- Create a 200 MiB partition on /dev/sdd.

- Format it as vfat (FAT32).

- Mount it at /vfatshare.

- Configure persistent mount with options:

    - uid=1000

    - gid=1000

    - umask=002

- Create a file as a regular user and verify read/write access.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  parted /dev/sdd mklabel gpt
  parted /dev/sdd mkpart primary 1MiB 201MiB

  partprobe
  udevadm settle

  mkfs.vfat /dev/sdd1

  mkdir /vfatshare

  mount /dev/sdd1 /vfatshare

  echo "UUID=$(blkid /dev/sdd1 -s UUID -o value) /vfatshare vfat defaults,uid=1000,gid=1000,umask=002 0 0" >> /etc/fstab

  umount /vfatshare
  mount -a

  df -h

  useradd student

  su - <student> -c "touch /vfatshare/file.txt"

  ls -l /vfatshare/file.txt 
  ```
</details>

---

## Task 4: Extend an Existing XFS Logical Volume Online

The logical volume /dev/mapper/vgdata-lvdata (mounted at /data) needs 1 GiB additional space.

### You must:

- Extend the LV by 1 GiB.

- Grow the XFS filesystem online.

- Verify size increase using df -h /data.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  vgdisplay vgdata
  lvextend -r -L +1G /dev/mapper/vgdata-lvdata
  df -h /data
  ```
</details>

---

## Task 5: Extend ext4 Logical Volume

The logical volume /dev/mapper/vgweb-lvweb (mounted at /web) needs additional space.

### You must:

- Extend the LV by 500 MiB (or use all free space if required).

- Resize the ext4 filesystem.

- Verify using df -h.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  vgdisplay vgweb
  lvextend -r -L +500M /dev/mapper/vgweb-lvweb
  df -h /web
  ```
</details>

---

## Task 6: Add New PV and Extend VG Before LV Extension

A new disk /dev/sdb is available to expand existing storage.

### You must:

- Create a 1 GiB partition.

- Initialize it as a physical volume.

- Add it to an existing volume group (e.g., vgdata).

- Extend an existing logical volume by 800 MiB.

- Grow the filesystem accordingly.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  parted /dev/sdb mklabel gpt
  parted /dev/sdb mkpart primary 1MiB 1.1G
  parted /dev/sdb set 1 lvm on
  partprobe
  udevadm settle

  pvcreate /dev/sdb1
  vgextend vgdata /dev/sdb1
  vgs vgdata
  lvextend -r -L +800M /dev/mapper/vgdata-lvdata
  df -h /data
  ```
</details>

---

## Task 7: Configure NFS Server Export

You must configure an NFS server to share project data.

### You must:

- Create /exports/projects.

- Set ownership to nobody:nobody.

- Apply permissions 1777.

- Export it to 192.168.122.0/24 with:

    - rw

    - sync

    - no_subtree_check

    - Restart NFS service.

    - Configure firewall.

    - Verify using showmount -e localhost.
  

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  mkdir -p /exports/projects
  chown nobody:nobody /exports/projects
  chmod 1777 /exports/projects

  dnf install nfs-utils -y
  systemctl enable --now nfs-server

  echo "/exports/projects  192.168.122.0/24(rw,sync,no_subtree_check)" >> /etc/exports

  exportfs -ra
  firewall-cmd --permanent --add-service=nfs
  firewall-cmd --reload

  showmount -e localhost
  ```
</details>

---

## Task 8: Mount NFS Share Manually and Persistently

A client system must access the shared NFS directory.

### You must:

- Mount /exports/projects manually at /mnt/projects.

- Use options:

- nfsvers=4

- soft

- timeo=10

- Configure persistent mount in /etc/fstab with _netdev.

- Test with mount -a.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  mkdir -p /mnt/projects
  mount -t nfs -o nfsvers=4,soft,timeo=10 server.com:/exports/projects /mnt/projects
  df -hT | grep nfs

  echo "server.com:/exports/projects    /mnt/projects    nfs    defaults,_netdev,nfsvers=4,soft,timeo=10    0 0" >> /etc/fstab

  umount /mnt/projects

  mount -a
  mount | grep /mnt/projects
  ```
</details>

---

## Task 9: Configure autofs for NFS User Home Directories

User home directories are exported via NFS and must be mounted on demand.

### You must:

- Install and configure autofs.

- Configure /etc/auto.master.

- Create wildcard indirect map in /etc/auto.home.

- Set timeout to 120 seconds.

- Verify auto-mount when accessing /home/student1.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf install autofs -y
  
  echo "/home    /etc/auto.home    --timeout=120" >> /etc/auto.master 
  echo "*        -fstype=nfs4,rw,soft            nfsserver.com:/home/&" >> /etc/auto.home

  systemctl enable --now autofs

  ls /home/student1
  cd /home/student1
  ```
</details>

---

## Task 10: Configure autofs Indirect Map for Project Share

Project data must be automatically mounted when accessed.

### You must:

- Configure autofs for /projects.

- Create indirect map entry for data.

- Mount nfsserver:/export/data automatically.

- Verify mount occurs on first access.

- Confirm auto-unmount after timeout.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf install autofs -y
  
  echo "/projects    /etc/auto.projects    --timeout=120" >> /etc/auto.master 
  echo "data        -fstype=nfs4,rw,soft            nfsserver:/export/data" >> /etc/auto.projects

  systemctl enable --now autofs

  ls -l /projects/data
  df -h | grep data

  # After 120 seconds of inactivity, it should disappear from 'df -h'
  ```
</details>

---

## Task 11: Create set-GID Directory for Team Collaboration

A shared directory must ensure files inherit the group ownership.

### You must:

- Create group developers (if needed).

- Create /opt/teamfiles.

- Set group ownership to developers.

- Apply set-GID bit (2775).

- Verify group inheritance with files created by multiple users.
  
<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  groupadd developers
  mkdir /opt/teamfiles

  chown :developers /opt/teamfiles

  chmod 2775 /opt/teamfiles

  usermod -aG developers developer1

  su - developer1 -c "touch /opt/teamfiles/file"

  ls -l /opt/teamfiles/file
  ```
</details>

---

## Task 12: Diagnose and Verify Sticky Bit Behavior

A public temporary directory must prevent users from deleting others' files.

### You must:

- Create /public/temp.

- Apply 1777 permissions.

- Test deletion behavior with different users.

- Verify sticky bit with ls -ld.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash

  mkdir -p /public/temp

  chmod 1777 /public/temp

  touch /public/temp/root_file

  su - developer1 -c "rm /public/temp/root_file"
  # Expected output: rm: cannot remove '/public/temp/root_file': Operation not permitted

  ls -l /public/temp/root_file
  ```
</details>

---

## Task 13: Break and Fix /etc/fstab (Rescue Simulation)

An incorrect UUID entry causes boot failure.

### You must:

- Simulate incorrect UUID for /mnt/data.

- Reboot into rescue/emergency mode.

- Fix /etc/fstab.

- Boot system normally.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  mount -o remount,rw /
  vi /etc/fstab
  systemctl daemon-reload
  mount -a
  exit
  ```
</details>

---

## Task 14: Mixed Task – Full Workflow

Provision a new storage environment for collaboration.

### You must:

- On /dev/sdc, create 1 GiB partition.

- Create PV → VG (vgextra) → LV (lvextra, 800 MiB).

- Format as XFS.

- Mount at /extra.

- Configure persistent mount.

- Create /extra/collaboration.

- Create group ops.

- Apply set-GID (2775).

- Add user bob to group ops.

- Verify group inheritance.


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  parted /dev/sdc mklabel gpt
  parted /dev/sdc mkpart primary 1MiB 1.1GiB

  partprobe
  udevadm settle

  pvcreate /dev/sdc1
  vgcreate vgextra /dev/sdc1
  lvcreate -n lvextra -L 800M vgextra

  mkfs.xfs /dev/vgextra/lvextra

  mount /dev/vgextra/lvextra /extra

  echo "UUID=$(blkid -s UUID -o value /dev/vgextra/lvextra) /extra xfs defaults 0 0" >> /etc/fstab

  umount /extra
  mount -a

  mkdir /extra/collaboration
  groupadd ops
  
  chown :ops /extra/collaboration

  chmod 2775 /extra/collaboration

  useradd -G ops bob 

  su - bob -c "touch /extra/collaboration/bob_file"

  ls -l /extra/collaboration/bob_file
  ```
</details>

---

## Task 15: Fine-Grained Permissions using ACLs

The management needs specific access rules for a sensitive directory that standard UGO (User, Group, Other) permissions cannot handle.

### You must:

- Create a file at /opt/manager_notes.txt.

- Set the owner to root and group to root.

- Ensure others have no permissions at all (0).

- Grant a specific user auditor (create it if it doesn't exist) read and execute permissions only, without changing the file's ownership or primary group.

- Verify the effective permissions using getfacl.

- Create a directory /opt/shared_reports and ensure that any new file created inside it automatically gives read access to the user auditor (Default ACLs).


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  touch /opt/manager_notes.txt

  chown root:root /opt/manager_notes.txt

  chmod o-rwx /opt/manager_notes.txt

  useradd auditor

  setfacl -m u:auditor:r-w /opt/manager_notes.txt

  getfacl /opt/manager_notes.txt

  mkdir -p /opt/shared_reports
  ```
</details>
  
---

## Task 15: Fine-Grained Permissions using ACLs

The management needs specific access rules for a sensitive directory that standard UGO (User, Group, Other) permissions cannot handle.

### You must:

- Create a file at /opt/manager_notes.txt.

- Set the owner to root and group to root.

- Ensure others have no permissions at all (0).

- Grant a specific user auditor (create it if it doesn't exist) read and execute permissions only, without changing the file's ownership or primary group.

- Verify the effective permissions using getfacl.

- Create a directory /opt/shared_reports and ensure that any new file created inside it automatically gives read access to the user auditor (Default ACLs).


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  touch /opt/manager_notes.txt

  chown root:root /opt/manager_notes.txt

  chmod o-rwx /opt/manager_notes.txt

  useradd auditor

  setfacl -m u:auditor:rx /opt/manager_notes.txt

  getfacl /opt/manager_notes.txt

  mkdir -p /opt/shared_reports

  setfacl -m u:auditor:rX /opt/shared_reports
  setfacl -m d:u:auditor:rX /opt/shared_reports
  ```
</details>