# RHCSA Path (RHEL 9)

This path focuses on building core Linux system administration skills
aligned with the **Red Hat Certified System Administrator (RHCSA)** exam.

All labs, projects, and documentation in this path are designed and
validated on **Red Hat Enterprise Linux 9 (RHEL 9)**, using Red Hat–
recommended tools, workflows, and best practices.

---

## RHCSA Exam Topics Covered

This path aligns with the official RHCSA exam objectives and covers the
following domains:

### 1. Understand and Use Essential Tools
- Access a shell prompt and execute commands with correct syntax
- Use input-output redirection (`>`, `>>`, `|`, `2>`, etc.)
- Analyze text using `grep` and basic regular expressions
- Access remote systems using SSH
- Switch users and work in multiuser environments
- Archive, compress, and extract files using `tar`, `gzip`, and `bzip2`
- Create and edit text files
- Create, copy, move, and delete files and directories
- Create hard and soft links
- Manage standard file permissions (ugo/rwx)
- Locate and use system documentation (`man`, `info`, `/usr/share/doc`)

### 2. Manage Software
- Configure access to RPM repositories
- Install, update, and remove RPM packages
- Install software from local files
- Configure and use Flatpak repositories
- Install and remove Flatpak applications

### 3. Create Simple Shell Scripts
- Use conditional execution (`if`, `test`, `[ ]`)
- Use looping constructs (`for`, etc.)
- Process script input parameters (`$1`, `$2`, ...)
- Use command output within scripts

### 4. Operate Running Systems
- Boot, reboot, and shut down systems
- Boot into different targets manually
- Interrupt the boot process to gain system access
- Identify and manage CPU- and memory-intensive processes
- Adjust process scheduling priorities
- Manage tuning profiles
- Locate and analyze system logs and journals
- Preserve system journals
- Start, stop, and verify network services
- Securely transfer files between systems

### 5. Configure Local Storage
- Create, delete, and manage GPT partitions
- Create and manage physical volumes, volume groups, and logical volumes
- Configure persistent mounts using UUIDs and labels
- Extend storage and swap non-destructively

### 6. Create and Configure File Systems
- Create, mount, and manage `ext4`, `xfs`, and `vfat` file systems
- Mount and unmount NFS file systems
- Configure and manage `autofs`
- Extend existing logical volumes
- Diagnose and resolve file permission issues

### 7. Deploy, Configure, and Maintain Systems
- Schedule tasks using `cron`, `at`, and systemd timers
- Configure services to start automatically at boot
- Configure default system targets
- Configure time synchronization clients
- Modify the system bootloader

### 8. Manage Basic Networking
- Configure IPv4 and IPv6 networking
- Configure hostname resolution
- Manage network services at boot
- Restrict network access using `firewalld` and `firewall-cmd`

### 9. Manage Users and Groups
- Create, modify, and delete local users
- Manage password policies and aging
- Create and manage local groups and memberships
- Configure privileged access

### 10. Manage Security and SELinux
- Configure firewall rules using `firewalld`
- Manage default file permissions
- Configure SSH key-based authentication
- Switch between enforcing and permissive SELinux modes
- Identify SELinux file and process contexts
- Restore default SELinux contexts
- Manage SELinux ports and boolean settings

## Disclaimer
This repository is a personal study guide and hands-on lab environment based on public Red Hat Exam Objectives (EX200). It does not contain actual exam questions, "dumps," or NDA-protected material. All scenarios are original and designed to simulate real-world system administration challenges.