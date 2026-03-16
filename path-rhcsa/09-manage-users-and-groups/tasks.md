# 09 – Manage Users and Groups - Tasks

These exercises simulate **real-world system administration scenarios** involving user management, password policies, group administration, and privileged access configuration on a Linux system.

## Task 1 — Create a New Developer Account

A new junior developer named **carlos** joins the web team. You must create a proper local account for him following company onboarding standards.

**Activities**

- Create a local user named `carlos`.

- Ensure the user has a **home directory.**

- Set the **default shell** to `/bin/bash`.

- Add the comment:

`Junior Developer - Web Team`

- Verify that the account was created successfully.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash 
  sudo useradd -m -c "Junior Developer - Web Team" -s /bin/bash carlos
  id carlos 
  ```
</details>

---

## Task 2 — Enforce Password Aging Policy

The company security policy requires passwords to **expire every 90 days** and warn users **7 days before expiration.**

**Activities**

- Configure password aging for user carlos.

- Set the **maximum password age to 90 days.**

- Configure a **7-day warning period before expiration.**

- Verify the configuration.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash 
  sudo chage -M 90 -W 7 carlos 
  sudo chage -l carlos
  ```
</details>

---

## Task 3 — Temporary Intern Account

An intern named **valeria** needs temporary access to the system for a short-term project.

**Activities**

- Create a user account named `valeria`.

- Ensure the account includes a **home directory.**

- Configure the account to **expire exactly 30 days from today.**

- Assign an **initial strong password** to the account.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo useradd -m valeria
  sudo chage -E $(date -d "+30 days" +%Y-%m-%d) valeria
  echo "valeria:superstrongpassword123!" | sudo chpasswd
  ```

</details>

---

## Task 4 — Offboarding an Intern

The internship ended and **valeria** has left the company.

**Activities**

- Remove the user account `valeria`.

- Ensure the **home directory is deleted.**

- Remove the **mail spool and related files** associated with the account.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo killall -u valeria
  sudo userdel -r valeria
  ```

</details>

---

## Task 5 — Create a Support Group

The IT department requires a new support group for helpdesk staff.

**Activities**

- Create a group named `helpdesk`.

- Assign the **GID 3000.**

- Verify that the group was created correctly.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo groupadd -g 3000 helpdesk
  grep helpdesk /etc/group 
   ```
</details>

---

## Task 6 — Add Multiple Users to a Group

Several employees need helpdesk access.

**Activities**

- Add users `carlos`, `ana`, and `miguel` to the `helpdesk` group.

- Ensure the group is added as a **secondary group.**

- Keep their **primary groups unchanged.**


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo usermod -aG helpdesk carlos
  sudo usermod -aG helpdesk ana
  sudo usermod -aG helpdesk miguel 

  grep helpdesk /etc/group

  ```
</details>

---

## Task 7 — Configure a Shared Project Directory

The directory `/opt/webapp` is used by developers collaborating on a shared project.

**Activities**

- Change the **group ownership** of `/opt/webapp` to `developers`.

- Enable the **SGID bit** on the directory.

- Verify that new files inherit the group ownership.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo chown :developers /opt/webapp
  sudo chmod g+s /opt/webapp

  touch /opt/webapp/file_developers
  ls -l /opt/webapp/file_developers
  ```
</details>

---

## Task 8 — Remove Privileged Access from an Old Account

A security audit discovered that an unused account named `testuser` still has administrative privileges.

**Activities**

- Remove `testuser` from the **wheel (sudo) group.**

- Lock the account so it **cannot be used for login.**

- Do **not delete** the account.


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo gpasswd -d testuser wheel
  sudo usermod -L testuser 
  id testuser
  ```
</details>

---

## Task 9 — Strengthen System Password Policy

The company is implementing stronger password policies across all systems.

**Activities**

- Configure the system so that:

    - Minimum password length is **12 characters.**

    - Minimum password age is **2 days.**

- Modify the appropriate configuration files.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  vi /etc/security/pwquality.conf
  minlen = 12
  vi /etc/login.defs
  PASS_MIN_DAYS   2
  ```
</details>

--- 

## Task 10 — Reset Password After Account Lockout

Senior system administrator **miguel** forgot his password during a long weekend.

**Activities**

- Reset the password for user miguel.

- Do not require the old password.

- Force the user to **change the password at the next login.**


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo passwd miguel
  sudo passwd -e miguel
  sudo chage -l miguel
  ```
</details>

---

## Task 11 — Limited Privileged Access for Deployment

A contractor named **javier** needs permission to run a deployment script but should **not have full sudo access.**

**Activities**

- Allow user `javier` to run the following command as root:

`/usr/local/bin/deploy.sh`

- Configure the permission **without requiring a password.**

- Ensure the user cannot execute other sudo commands.


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  visudo -f /etc/sudoers.d/javier
  javier ALL=(ALL) NOPASSWD: /usr/local/bin/deploy.sh
  sudo -l -U javier
  ```
</details>

---

## Task 12 — Reduce Excessive Group Membership

A security audit shows that user **ana** belongs to too many groups.

Current groups:

`wheel, developers, dbadmins, backup`

**Activities**

- Remove user `ana` from the **wheel group.**

- Ensure she **remains a member of the other groups.**


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo gpasswd -d ana wheel 
  id ana
  groups ana
  ```
</details>

---

## Task 13 — Create a Service Account

Monitoring software requires a service account to check the status of the NGINX server.

**Activities**

- Create a user named:

`nginx-monitor`

- Add the comment:

`NGINX monitoring service account`

- Ensure the account:

    - Has **no login shell**

    - Has **no home directory**

    - Cannot be used for interactive login.

<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo useradd -r -M -c "NGINX monitoring service account" -s /sbin/nologin nginx-monitor 
  id nginx-monitor
  getent passwd nginx-monitor
  ```
</details>

---

## Task 14 — Configure Access to Tape Devices

The backup system runs using the account backupsvc and needs access to tape devices.

**Activities**

- Verify if the group `tape` exists.

- If it does not exist:

    - Create the group `tape` with **GID 500.**

    - Add user `backupsvc` to the `tape` group.


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo getent group tape || sudo groupadd -g 500 tape
  sudo gpasswd -a backupsvc tape
  groups backupsvc
  ```
</details>

---

## Task 15 — Emergency Offboarding Procedure

A senior administrator named `former-admin` left the company unexpectedly. Immediate action is required to secure the system.

**Activities**

- Lock the user account immediately.

- Remove the user from all **privileged groups** such as `wheel`.

- Change the login shell to:

`/sbin/nologin`

- Configure the account to **expire in 7 days.**


<details>

  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  sudo usermod -L former-admin
  sudo gpasswd -d former-admin wheel
  sudo usermod -s /sbin/nologin former-admin
  sudo chage -E $(date -d "+7 days" +%Y-%m-%d) former-admin
  
  sudo chage -l former-admin
  id former-admin
  groups former-admin

  ```
</details>