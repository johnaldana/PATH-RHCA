# 06 – Create and Configure File Systems
## Project 06 - Enterprise Storage & Collaboration Infrastructure Deployment

# 1.- Executive Summary

TechNova Solutions is a 50-person technology startup experiencing rapid growth.  
The company requires a redesigned storage architecture to support development workflows, financial data protection, centralized home directories, and future scalability.

As the Linux Systems Administrator, you are responsible for designing, implementing, documenting, and automating a secure and resilient storage solution using native Linux technologies.

The solution must:

- Survive reboots. All configurations must be validated after a full system reboot to confirm persistence and dependency correctness.
- Be production-ready
- Be fully documented
- Be automated via script
- Follow enterprise best practices

---

# 2. Infrastructure Overview

## Systems

- **server1** – NFS Server (192.168.56.10)
- **client1** – Primary Workstation / Storage Node

## Available Disks (client1)

- `/dev/sdb` – 3 GiB (LVM scratch space)
- `/dev/sdc` – 3 GiB (ext4 operational volume)
- `/dev/sdd` – 1 GiB (vfat cross-platform share)

## Available Disk (server1)

- `/dev/sdb` – NFS export storage

## Groups

- developers
- finance
- ops

## Users

- dev1, dev2 (developers)
- fin1 (finance)
- auditor (external contractor)
- bob (ops)

---

# 3. Business Requirements

## 3.1 Developer High-Performance Scratch Space

The Development team requires fast local storage for builds and temporary artifacts.

### Requirements

- Use LVM on `/dev/sdb`
- size 2G
- Filesystem: **XFS**
- Mounted at `/scratch`
- Must support online expansion
- Mounted persistently using UUID
- Optimized with `noatime`
- Survive reboot

The solution must allow non-disruptive extension when storage demand increases.

---

## 3.2 Operational Data Volume (ext4)

The Operations team requires a stable, traditional filesystem for internal tooling and scripts.

### Requirements

- Use `/dev/sdc`
- Filesystem: **ext4**
- Mounted at `/team`
- Mounted persistently
- Must allow mount/unmount operations safely
- Filesystem integrity must be verifiable
- UUID must be documented in baseline

---

## 3.3 Cross-Platform Share (vfat / FAT32)

The organization requires a Windows-compatible share for temporary file exchange.

### Requirements

- Use `/dev/sdd`
- Filesystem: **vfat (FAT32)**
- Mounted at `/usbshare`
- Configured with  `gid=$(getent group developers | cut -d: -f3)`, and `umask=002`
- Persistent configuration
- Usable by regular Linux users

---

## 3.4 Centralized NFS Storage (server1)

The company requires centralized shared storage.

### Exports Required

- `/exports/homes` – Centralized home directories
- `/exports/code` – Shared development repository

### Requirements

- NFS service enabled and persistent
- Exports restricted to internal subnet
- Secure export options (sync, no_subtree_check)
- Firewall properly configured
- Export validation performed

---

## 3.5 NFS Client Configuration (client1)

The client must integrate centralized storage seamlessly.

### Requirements

- Manual mount capability
- Persistent mount via `/etc/fstab` with `_netdev`
- autofs for on-demand home directory mounting
- Automatic unmount after inactivity
- Must survive reboot
- Network dependency handled correctly

---

## 3.6 Collaborative Development Directory (set-GID)

A shared repository must enforce group inheritance.

### Requirements

- Directory: `/opt/team-repo`
- Group: developers
- Permission mode: `2775`
- New files inherit group automatically
- Only authorized users may modify contents

---

## 3.7 Public Drop Directory (Sticky Bit)

A public internal drop location must allow open file creation but prevent deletion of others’ files.

### Requirements

- Directory: `/public/drop`
- Permission mode: `1777`
- Sticky bit enforced
- Multi-user behavior validated
- Must behave like `/tmp`

---

## 3.8 Finance Sensitive Reports (ACL Implementation)

The Finance team stores confidential reports requiring controlled access.

### Requirements

- Directory: `/opt/finance-reports`
- Group ownership: finance
- Directory permissions: `770`
- Regular users denied access
- Auditor must have read-only access
- Ownership must not change
- Default ACL must ensure new files inherit read access for auditor
- Verification required using `getfacl`

The solution must clearly demonstrate understanding of:

- `r` vs `rx`
- `X` vs `x`
- Default ACL inheritance

---

## 3.9 Online LVM Extension

The scratch logical volume must be extended without downtime.

### Requirements

- Extend logical volume 1G
- Grow filesystem online
- No unmount required
- Validate capacity increase
- Document before and after state

---

# 4. Baseline Documentation Requirement

Before implementation, create:

```bash
/baseline/06-create-and-configure-file-systems_$(date +%F)
```

This directory must store:

- `lsblk`
- `blkid`
- `vgs`
- `lvs`
- `pvs`
- `df -hT`
- `mount`
- `cat /etc/fstab`
- `findmnt`
- `exportfs -v`
- `getfacl` outputs (where applicable)

After project completion:

- Capture updated system state
- Compress directory:

```bash
/baseline/06-create-and-configure-file-systems_$(date +%F).tar.gz
```