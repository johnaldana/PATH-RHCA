# 07 - Deploy, configure and maintain systems
## Project 07 - Production Web Server 

You are a Linux System Administrator at **NovaCart E-Commerce**, a growing online retail company.

The company has provisioned a new Red Hat Enterprise Linux server that will host a production web application. The operating system is already installed, but the system has not yet been configured according to company standards.

Your responsibility is to prepare the server for production use by implementing a secure, automated, and maintainable baseline configuration.

All work must be:

- Organized
- Structured
- Logged
- Reproducible
- Persistent after reboot
   
For auditing purposes. All artifacts must be stored under:

```bash
/baseline/07-deploy-configure-and-maintain-systems_<YYYY-MM-DD>/
```
---

## Phase 1 – Production Baseline Configuration

The infrastructure team requires all production servers to follow a strict baseline policy before application deployment.

The server must be properly identified, secured, updated, and prepared for production workloads.

**You must:**

- Configure the system hostname to match the production naming convention.
    
    `webprod01.novacart.local`

- Ensure the system is fully updated and patched to the latest  available RHEL9 packages .

- Configure the firewall to allow only the following services:
  
  - HTTP
  - HTPPS
  - SSH

- Confirm SELinux is enabled and enforcing.

- Install essential administrative tools required for server management.

  - vim
  - tree
  - bash-completion
  - httpd
  - chrony
  - policycoreutils-python-utils        

- Verify that the system state persists after reboot.

  - SElinux remains enforcing
  - Firewall rules persist
  - Hostname remain correct

---

## Phase 2 – Repository and Package Management Strategy

NovaCart operates in hybrid infrastructure environments. Some servers use official Red Hat repositories, others rely on remote third-party repositories, and certain environments depend on internal local repositories.

The production server must be capable of installing and managing packages from multiple trusted sources.

**You must:**

- Validate access to the official Red Hat software repositories.

- BaseOS and AppStream repositories must be enabled.

- Configure an additional remote repository for extended software support.

  - `https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm`

- Create of a local repository hosted on the server.

  - Create directory: `/localrepo`.

  - Place at least two RPM packages inside it (for example: htop, ncdu).

  - Generate repository metadata.

  - Create a .repo file under `/etc/yum.repos.d/`

  - Name the repository: `novacart-local`

  - The repository must use: `file:///localrepo` as base URL.

  - GPG check must be disabled.

- Verify that the system can install packages from each source.

- Ensure repository configurations are persistent and secure.

---

## Phase 3 – Web Server Deployment and Service Management

The server will host the company’s production web application using an Apache-based stack.

The web service must be reliable, automatically start at boot, and be fully manageable through system services.

**You must:**

- Install and configure the Apache web server.

- Ensure the service starts automatically on boot.

- Deploy a basic web page to confirm functionality.

    -`/var/www/html/index.html`

    Content must contain: `Welcome to NovaCart Production Server – webprod01`

- Validate service status and operational reliability.

---

## Phase 4 – Automation and Scheduled Maintenance

Production systems must perform automated tasks to ensure stability, monitoring, and data protection.

The organization requires implementation of:

- One-time emergency tasks

- Recurring maintenance operations

- Modern service-based scheduled jobs

**You must:**

### A. One-Time Emergency Backup (Using at)

- Schedule a one-time backup that:

  - Archives `/var/www/html`

  - Stores the archive in `/backup`

  - File format: `emergency-web-<YYYYMMDD>.tar.gz`

  - Runs exactly 5 minutes after scheduling

- After scheduling, verify the job is registered.

### B. Recurring Maintenance Task (Using cron)

- Create script:

  `/usr/local/bin/system-health.sh`

- The script must:

  - Log disk usage

  - Log memory usage

  - Log top 5 processes by memory consumption

  - Append output to:

  `/var/log/system-health.log`

- Schedule the script to run:

  - Every day at 02:00 AM

### C. Weekly Full Backup (Using cron)

Schedule a weekly backup that:

  - Archives `/var/www`

  - Stores backup in `/backup`

  - File format: `weekly-full-<YYYYMMDD>.tar.gz`

  - Runs every Sunday at 03:00 AM

### D. Daily Backup Using systemd Timer

Create:

- A service unit

- A timer unit

Requirements:

- Backup `/var/www/html`

- Store file in `/backup`

- Format: `daily-web-<YYYYMMDD>.tar.gz`

- Execute daily at 01:00 AM

- Must survive reboot if the system was powered off during scheduled time

- Verify the timer is active.
  
---

## Phase 5 – User and Permission Management

The server will be accessed by multiple internal teams, including:

- Web administrators

- Backup operators

- Monitoring personnel

Each group must have controlled and limited access according to the principle of least privilege.

**You must:**

- Create the following groups:

    - webadmin
    - backupops
    - monitoring

- Create the following users:

  - deploy (member of webadmin)
  - backupuser (member of backupops)
  - monitor1 (member of monitoring)

Directory Security Requirements

1. `/var/www` must:
   - Be owned by root
   - Group-owned by webadmin
   - Have permissions allowing group read/execute only

2. `/backup` must:
   - Be owned by root
   - Group-owned by backupops
   - Allow only root and backupops full access

3. monitoring users must NOT have write access to either directory.

Validate access restrictions by switching users.

---

## Phase 6 – Time Synchronization Configuration

Accurate time synchronization is critical for:

- Transaction logging

- Security auditing

- Compliance reporting

- Database consistency

The server must be configured as a time service client using enterprise-standard practices.

**You must:**

- Install and configure a time synchronization service.

- Define appropriate upstream time sources.

    - 0.pool.ntp.org
    - 1.pool.ntp.org

- Verify synchronization status and stability.

- Demonstrate the ability to manually correct time drift.

- Ensure the service starts automatically at boot.

---

## Phase 7 – Boot Target Configuration

Depending on the environment, servers may need to boot into graphical or non-graphical modes.

Production systems typically operate in a non-graphical target for performance and security reasons.

**You must:**

- Identify the current default boot target.

- Modify the system to boot into: `multi-user.target`

- Reboot and verify the change.

- Restore the production-appropriate boot target.

---

## Phase 8 – Bootloader Hardening and Kernel Parameter Management

To protect against unauthorized physical access and kernel manipulation, the bootloader must be secured.

Additionally, certain kernel parameters must be configured to enhance logging and security monitoring.

**You must:**

- Inspect the current bootloader configuration.

- Modify kernel boot parameters according to security policy.

  **Kernel Parameters**

  Modify GRUB configuration to ensure kernel command line includes:

  - `quiet splash audit=1`

  **GRUB Timeout**

  Set bootloader timeout to:

  `2 seconds`

  **GRUB Password Protection**

  Configure GRUB to:

  - Require password to edit boot entries

  - Protect against unauthorized kernel parameter changes

  - Regenerate boot configuration safely.

  - Reboot and validate protection.

---

## Phase 9 – Post-Reboot Validation and Operational Audit

Production changes are never considered complete until validated after a full system reboot.

A reboot simulates real production events such as patching, kernel upgrades, or power failures.


**After rebooting the system, you must verify:**

- Hostname correct

- Web services are running.

- Scheduled tasks remain active.

- systemd timer active.

- Time synchronization is functional.

- Firewall and SELinux policies are enforced.

- Boot target configuration is correct.

- Bootloader security settings remain applied.

- User access controls function properly.

All validation results must be documented in the `project-log.txt`

