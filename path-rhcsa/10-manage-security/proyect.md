# 10-manage-security
## Project 10: Enterprise Linux Security Hardening and SELinux Troubleshooting

You have recently joined the infrastructure team of a mid-sized healthcare technology company. The company hosts internal applications and public-facing services that handle sensitive data, including patient records and analytics dashboards.

Following a recent internal security audit, multiple critical findings were reported on one of the production servers:

`sysadmin-lab-01 (RHEL 9)`

The system is already running:

- Apache → `httpd`

- MariaDB → `mariadb`

- SSH → `sshd`

- FTP → `vsftpd`

The audit revealed:

- Weak SSH access controls allowing password-based authentication

- Excessive firewall exposure, including unnecessary services open to the public

- Insecure default file permission policies

- Misconfigured SELinux settings causing intermittent failures in Apache and database connectivity

- Services running but not properly aligned with SELinux policies (ports, contexts, and booleans)

Your manager has asked you to take full ownership of this server, apply proper security hardening, and ensure all services operate correctly under SELinux enforcing mode.

**Operational Requirements**

As part of company standards:

- All work must be performed as root (EUID = 0)

- You must document your work for auditing purposes

- No security control should be disabled unless explicitly justified (especially SELinux)

- Every change must be verifiable and reversible

- Before starting, create a working directory where all your evidence, logs, and tests will be stored:

`/baseline/10-manage-security_$(date +%F)`


## Phase 1: Firewall Exposure Review and Remediation

The audit report indicates that the server is exposing more services than required, increasing the attack surface.

Currently, multiple services—including database and FTP—may be accessible from external networks.

**What You Need to Do**

- Identify which firewall zones are active and how interfaces are assigned

- Determine which services and ports are currently open

- Apply a restrictive model where:

    - Only essential web and remote access services are publicly available

    - MariaDB MUST NOT be reachable from any external network

    - FTP access is not exposed externally at all

- Introduce a new firewall zone to represent internal network trust boundaries

- Assign the appropriate source network to this zone

- Apply different rules depending on whether traffic is internal or external

**Requirements:**

- Use the following firewall zones:

  - `public` → external traffic  
  - `company-internal` → internal trusted network  

- Assign interface:

  - `ens160` MUST belong to `public`

- Define internal trusted network:

  - `192.168.10.0/24` MUST be associated with `company-internal`

- Apply the following access rules:

  **Public zone MUST allow ONLY:**

  | Service | Port |
  |--------|------|
  | SSH | 2222 |
  | HTTP | 80 |
  | HTTPS | 443 |

  **Internal zone MUST allow ONLY:**

  | Service | Port |
  |--------|------|
  | MariaDB | 3306 |

- Ensure the following are NOT accessible externally:

  - FTP (21)
  - Default SSH port (22)
  - Any other unnecessary service

- All changes MUST be persistent

- New SSH port (2222) MUST be allowed in firewall BEFORE removing port 22

**Validation (Required):**

- firewall-cmd --list-all-zones
- ss -tlnp
- curl http://localhost
  
--- 

## Phase 2: Default Permission Policy Hardening

The audit found that newly created files are too permissive, potentially exposing sensitive data to unauthorized users.

**What You Need to Do**

- Investigate current default permission settings at both system and user levels

- Apply stricter defaults so that:

    - Regular users cannot create world-readable or writable files

    - Administrative (root) operations are even more restricted

- Ensure these settings apply not just to current sessions, but persist across:

    - New logins

    - New users

**Requirements**

- Apply the following default permission policies:

  | User Type | Umask |
  |----------|--------|
  | Regular users | 027 |
  | root | 077 |

- Configuration MUST be:

  - System-wide
  - Persistent across reboots
  - Applied to new users and login sessions

- Verify that new files created by:

  - A regular user
  - root

  follow the expected permission model

---

## Phase 3: SSH Access Lockdown

The audit flagged SSH as a major risk:

- Password authentication is enabled

- Root access is not properly restricted

- The default port is being scanned and targeted


**What You Need to Do**

- Transition authentication to a key-based model only

- Eliminate password-based login entirely

- Harden root access according to policy

- Move SSH away from its default port to reduce automated attacks

- Limit access to only authorized users or groups

**Requirements**

- SSH MUST run on port: `2222`

- Enforce authentication model:

  - Key-based authentication ONLY
  - Password authentication MUST be disabled

- Root access MUST follow:

  - No password login allowed

- Restrict SSH access:

  - Only authorized users MUST be able to connect

- A dedicated administrative user MUST exist:

  - `sysadmin`

- Key-based authentication MUST be tested locally on the server

- Existing SSH session MUST remain active during changes to avoid lockout

- Ensure SSH service remains accessible after configuration changes

- Validate that SSH access works using key-based authentication and fails using password authentication

---

## Phase 4: SELinux Mode Control and Verification

Previous administrators switched SELinux between permissive and enforcing without proper understanding, leading to inconsistent behavior.

**What You Need to Do**

- Identify the current SELinux mode and policy

- Temporarily relax enforcement to observe differences in system behavior

- Restore full enforcement in a controlled way

- Ensure the system always boots in enforcing mode going forward

**Requirements**

- 1. Identify:

    `sestatus`

- 2. Temporarily switch:

    Enforcing → Permissive

- 3. Return to enforcing permanently:

    `/etc/selinux/config`

---

## Phase 5: SELinux Context Investigation

Applications are failing intermittently because files and processes may not have correct SELinux labels.

**What You Need to Do**

- Inspect file contexts in web directories and configuration files

- Analyze process contexts for running services

**Requirements**

- Inspect EXACTLY these:

```bash
/var/www/html/index.html
/var/www/html/test.html
/etc/ssh/sshd_config
```
- Inspect processes:

```bash
ps auxZ | grep httpd
ps auxZ | grep sshd
```
---

## Phase 6: SELinux Context Restoration

Improper file operations (copying/moving) have introduced incorrect SELinux contexts, causing services like Apache to fail.

**What You Need to Do**

- Simulate context issues by placing files incorrectly

- Apply appropriate methods to restore:

- Entire directory structures

- Individual files

- Ensure services regain proper access

**Requirements**

- Simulate incorrect SELinux contexts on:

  - `/var/www/html/index.html`

- Restore correct SELinux context for:

  - The individual file
  - The entire `/var/www/html/` directory

- Verify that Apache regains access to restored files

---

## Phase 7: SELinux Port Alignment

Some services have been reconfigured to use non-standard ports, but SELinux was not updated accordingly, resulting in blocked communication.

**What You Need to Do**

- Identify which ports are currently associated with key services

- Align SELinux policies with:

- New SSH port

- Additional web service port

- Clean up any unnecessary or incorrect port assignments

**Requirements**

- The system is using the following non-standard ports:

  | Service | Port |
  |--------|------|
  | SSH | 2222 |
  | HTTP (additional) | 8080 |

- SELinux MUST be updated to allow these services to operate correctly

- Verify that:

  - SSH is reachable on port 2222
  - Web service responds on port 8080

- Remove any incorrect or unnecessary SELinux port mappings

---

## Phase 8: SELinux Boolean Configuration

The web application requires additional capabilities that are currently blocked by SELinux, such as database connectivity and access to user directories.

**What You Need to Do**

- Identify relevant booleans affecting:

- Web server behavior

- Database connectivity

- FTP access

- Enable only what is necessary, following least-privilege principles

**Requirements**

- Configure SELinux to allow:

  - Web server communication with MariaDB
  - Web server access to user home directories
  - FTP service read/write access in user directories

- All changes MUST be persistent

- Verify functionality:

  - Web application can connect to database
  - FTP upload works correctly
 
---

## Final Validation

After completing all phases, the system MUST meet the following conditions:

- SSH:
  - Accessible ONLY via port 2222
  - Password authentication disabled

- Firewall:
  - Only required ports exposed externally
  - Database NOT publicly accessible

- SELinux:
  - Running in Enforcing mode
  - No service failures due to policy restrictions

- Services:
  - Apache must serve content correctly
  - MariaDB must be reachable internally
  - FTP must function only within allowed scope

All validations MUST be demonstrated using command output

---

## Final Deliverable

At the end of your work, you must create a compressed archive:

`/baseline/10-manage-security_YYYY-MM-DD.tar.gz`

The archive must include:

- Command outputs showing system state before and after changes

- Logs of executed commands

- Test artifacts used for validation

- Evidence of successful validation for each phase

