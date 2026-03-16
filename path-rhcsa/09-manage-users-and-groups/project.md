# 09 - Manage Users and Groups
## Project - 09: Onboarding, Access Control & Offboarding Cycle

TechNova Inc. is a software development company that maintains an internal Linux server used by development and infrastructure teams.

The server runs **RHEL9** and is used for:

- Internal development tools

- Shared project directories

- System administration tasks

Recently several operational events occurred:

- Two employees **left the company unexpectedly**

- Four **new employees joined the organization**

- A **security audit** detected:

    - Inactive user accounts still present on the system

    - Users with unnecessary **administrative privileges**

    - Inconsistent password aging policies

    - Shared directories without proper group configuration

As the Linux System Administrator, your responsibility is to:

- Perform a system audit

- Secure old accounts

- Configure password policies

- Onboard new employees

- Manage groups and permissions

- Configure controlled administrative access

- Document the changes made to the system

**Lab Structure**

All artifacts generated during this project must be stored in:

`/baseline/09-manage-users_DATE`

The directory must contain the following files at the end of the project:

`audit_initial.txt`
`final_audit.txt`
`access_report.md`

After completing the lab, create a **compressed archive** of this directory.

---

## Phase 1 — Initial System Audit

Before applying changes, perform a system audit to understand the current state of user accounts.

Collect information about:

- Existing user accounts

- Members of the **wheel** group

- Accounts that may no longer be needed

During the audit, the following accounts were identified as suspicious:

`olddev1`
`testadmin`
`intern2024`

Account information:

| **Account** |	**Description** |
| olddev1 |	Former developer who left the company |
| testadmin | Temporary account used during testing |
| intern2024 | Internship account created last year |

Save the results of the initial audit in:

`audit_initial.txt`

---

## Phase 2 — Offboarding Former Employees

TechNova follows a defined offboarding security policy when employees leave the company.

**Offboarding Policy**

When an employee leaves:

- 1. The account must be **locked immediately.**

- 2. Administrative privileges must be removed.

- 3. The login shell must be changed to a **non-interactive shell.**

- 4. The account must be configured to **expire in 7 days** for auditing purposes.

- 5. Accounts should **not be deleted immediately** to preserve historical data.

**Tasks**

Apply the offboarding policy to the following accounts:

`olddev1`
`testadmin`

Ensure that these accounts:

- Cannot log in

- Are no longer members of wheel

- Use a non-interactive login shell

- will expire within the specified time frame

--- 

**Internship Account**

The account:

`intern2024`

belongs to a temporary intern whose contract ended last year.

Company policy states that expired internship accounts should be **fully removed.**

**Tasks**

Remove the account from the system and ensure that:

- The home directory is deleted

- Related files are removed if applicable

---

## Phase 3 — Configure Password Aging Policy

The security audit also revealed inconsistent password policies across the system.

TechNova requires the following password aging configuration:

| **Setting** |	**Value** |
| :--- | :--- |
| Maximum password age | 90 days |
| Minimum password age | 2 days |
| Password expiration warning |	14 days |

**Tasks**

- Configure the system-wide password aging policy.

- Apply the policy to existing regular user accounts.

System accounts should **not be modified.**

---

## Phase 4 — Onboarding New Employees

Four new employees joined the company.

Create the following user accounts:

| **Username** | **Role** |
| :--- | :--- |
| lucia | Frontend Developer |
| mateo	| Backend Developer |
| sara | Junior System Administrator |
| victor | Security Consultant |

Each account must:

- Include a home directory

- Use `/bin/bash` as login shell

- Include a descriptive comment describing the role

Assign an initial password to each account and require the user to change the password at their first login.

---

## Phase 5 — Group Administration

The organization manages access to resources using groups.

Ensure the following groups exist on the system:

`developers`
`dbadmins`
`deployers`

Assign users to groups based on their responsibilities.

| **User** | **Groups** |
| :--- | :--- |
| lucia | developers |
| mateo | developers, dbadmins |
| sara | developers, deployers |
| victor | none |

---

## Phase 6 — Controlled Administrative Access

The system administrator wants to avoid granting full administrative access through the **wheel** group to new users.

Instead, specific administrative actions should be allowed through controlled **sudo rules.**

**Requirements**
**Sara**

Sara is responsible for application uptime. She needs to manage the web server service but should not have full system control.

- **Allowed Commands:** `/usr/bin/systemctl status nginx`, `/usr/bin/systemctl restart nginx`

- **Authentication:** Password required.

**Victor**

Victor is performing system diagnostics and security audits. He needs access to specific reporting tools without the friction of entering a password every time.

- **Allowed Commands:** `/usr/bin/df`, `/usr/bin/du`, `/usr/bin/journalctl`

- **Authentication:** No password required (`NOPASSWD`).

Configure the necessary sudo rules to enforce these restrictions.

---

## Phase 7 — Shared Project Directories

Developers collaborate on shared projects stored under:

`/opt/projects/webapp`
`/opt/projects/api`

These directories must allow collaboration between members of the **developers** group.

**Tasks**

Configure the directories so that:

- The group owner is **developers**

- Developers can read and write files

- New files created inside these directories inherit the correct group ownership

---

## Phase 8 — Audit Log Access

System audit logs are stored in:

`/var/log/audit`

A new group should be created to allow limited access to these logs.

**Tasks**

Create a group named:

`auditread`

Add the following users to this group:

`sara`
`victor`

Configure file permissions so that members of this group can **read audit logs but cannot modify them.**

---

## Phase 9 — Final Verification

After completing all configuration tasks, verify the system state.

Check:

- Members of the **wheel group**

- Members of the **developers group**

- Account information for all new users

- Configured sudo privileges

Save the results in:

`final_audit.txt`

---

## Phase 10 — Documentation

Create a final report:

`access_report.md`

The report should summarize the work performed.

Include:

**Accounts Secured**

Which accounts were locked or removed.

**Password Policies**

Description of the password aging configuration applied.

**New Users**

List of users created and their assigned roles.

**Access Control**

Summary of group assignments, sudo configuration, and shared directory permissions.

**Security Recommendations**

Suggestions for improving account management in the future.

--- 

**Final Deliverable**

The directory:

`/baseline/09-manage-users-and-groups_DATE`

must contain:
code 
`audit_initial.txt`
`final_audit.txt`
`access_report.md`

Finally create a compressed archive of the directory for record keeping.