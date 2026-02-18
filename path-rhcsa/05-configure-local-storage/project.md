# 05 – Configure Local Storage
## Project 05 - Emergency Storage Expansion and Swap Optimization for Production Database Server

The production database server **db-prod-01** is experiencing critical performance degradation due to two main factors:

- **Insufficient swap space** – Swap usage consistently exceeds 80% during nightly batch jobs, triggering OOM killer alerts.

- **Database storage nearing capacity** – /var/lib/mysql LV is at 90% usage, slowing queries and risking outages.

- The server has the following storage configuration:

    | **Disk** | **Current Usage / Notes** |
    | :--- | :--- |
    | /dev/sda | OS boot disk (ignore for project) |
    | /dev/sdb | 20 GiB swap partition (too small) |
    | /dev/sdc | 60 GiB empty disk (new, available) |
    | /dev/sdd | 100 GiB disk, VG vg_db, LV lv_mysql (50GiB allocated, ~45 GiB used) |

The project requires **non-destructive, online operations** with zero downtime for the database.

---

## 2. Business Objectives

### 2.1 Swap Optimization

- Replace the old small swap partition on /dev/sdb1 with a larger swap LV.

- Provide at least 12–16 GiB additional swap capacity (total swap should reach ~32–36 GiB).

- Activate swap immediately and persist across reboots using UUID in /etc/fstab.

- Safely remove the old swap partition after migration.

### 2.2 Database Storage Expansion

- Extend existing volume group vg_db.

- Increase lv_mysql by 30 GiB online, without unmounting.

- Grow the XFS filesystem to reflect the additional space.


### 2.3 Utility Storage for Logs and Backups

- Create a new 20 GiB logical volume lv_logs.

- Format with XFS and assign filesystem label DB_LOGS_2026.

- Mount at /var/log/db_backups.

- Persist the mount in /etc/fstab using LABEL (not UUID or device path).

### 2.4 Cleanup and Verification

- Remove old swap partition /dev/sdb1 after migration.

- Confirm all mounts, swap, and filesystem expansions survive a simulated reboot (mount -a, swapon -a).

- Record verification outputs for:

    - Active swap devices and free memory.

    - Mounted filesystems and available space.

    - Logical volume and volume group status.

## 3. Project Constraints & Safety Rules

- No downtime for /var/lib/mysql.

- Non-destructive operations only; do not overwrite existing database data.

- Use GPT partitioning for any new disks.

- Test all /etc/fstab changes with mount -a before considering permanent.

- Execute all commands with root privileges (sudo).

- Store all evidence files in a single project folder, /baseline/05_Local_Storage_Management_YYYY-MM-DD/, no subfolders.

- At the end, create a compressed archive .tar.gz of the folderfor repository submission or audit purposes.

## 4. Evidence Management Guidelines

- All output and verification data should be captured in individual files inside the project folder:

    | **Evidence Type** | **Suggested Filename** |
    | :--- | :--- | 
    | Swap status and memory | swap_status.txt, free_memory.txt |
    | LV/VG status | lv_status.txt, vg_status.txt | 
    | Filesystem usage | mysql_df.txt |
    | Disk/partition info |	lsblk.txt, blkid.txt |
    | /etc/fstab before and after |	fstab_before.txt, fstab_after.txt |
    | Last logs | logs.txt
    | lsblk -f, swapon --show, findmnt --verify | final_verification.txt |


## 5. Execution Flow (High-Level)

- Prepare project folder for logs and verification.

- Swap migration

    Deactivate old swap, create new swap LV, activate, and persist in /etc/fstab.

- Database storage expansion

    Partition new disk, add PV to vg_db, extend lv_mysql, grow filesystem online.

- Logs/backup LV creation

    Create LV, format, mount temporarily, update /etc/fstab using label.

- Cleanup

    Remove old swap partition and verify freed space.

- Verification

    Check all mounts, swap, LVs, VGs, filesystem sizes, and save outputs.

- Archive project folder

    Produce 05_Local_Storage_Management_YYYY-MM-DD.tar.gz with all evidence files.