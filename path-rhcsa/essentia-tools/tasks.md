# 01 – Understand and Use Essential Tools  
**RHCSA Tasks – RHEL 9**

These tasks are designed to simulate **real RHCSA-style scenarios** and
day-to-day system administration challenges.

All tasks must be completed **using the command line only**.
Assume you are working on a **headless RHEL 9 server**.

---

## Task 1 – Restricted Log Analysis

A system administrator reports repeated authentication failures on the server.

### Requirements
- Identify all failed SSH login attempts.
- Count how many failures occurred.
- Store the result in `/root/ssh_failures.txt`.

### Constraints
- Do not edit log files.
- Use pipes and text-processing commands only.
- Output must contain **only the final count**.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  journalctl -u sshd | grep "Failed password" | wc -l > /root/ssh_failures.txt
  ```
  **Check**

  ```bash
  cat /root/ssh_failures.txt
  ```
</details>

---

## Task 2 – Controlled Output Redirection

Create a command that lists all files in `/etc` **recursively**, including permissions,
and saves the output to `/tmp/etc_audit.txt`.

### Requirements
- Standard output must go to `/tmp/etc_audit.txt`.
- Error messages must go to `/tmp/etc_errors.log`.

### Constraints
- No combined redirection (`&>`).
- Do not overwrite existing files unintentionally.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  find /etc -type f -exec ls -lh {} \; 1> /tmp/etc_audit.txt 2> /tmp/etc_errors.log
  ```
  **Check**

  ```bash
  cat /tmp/etc_audit.txt 
  cat /tmp/etc_errors.log
  ```
</details>

---

## Task 3 – Safe Cleanup Script (Dry Run)

You are asked to review a cleanup operation before it is executed in production.

### Requirements
- Identify all `.log` files larger than 20MB under `/var/log`.
- Display their full paths.
- Do **not** delete anything.

### Constraints
- Use command-line tools only.
- Output must be human-readable.
- No interactive commands.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  find /var/log -type f -name "*.log" -size +20M -exec ls -lh {} \;
  ```
</details>

---

## Task 4 – User Environment Verification

A user claims their environment variables are not loading correctly.

### Requirements
- Switch to the user `operator` using the **correct method**.
- Verify the user's home directory and default shell.
- Confirm whether `/etc/profile` is being applied.

### Constraints
- Do not modify user configuration files.
- You must use built-in system documentation to validate behavior.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  su - operator ; echo $HOME ; echo $SHELL ; echo $PATH
  ```
</details>

---

## Task 5 – Symbolic vs Hard Link Investigation

You find two files pointing to the same content in `/tmp`.

### Requirements
- Determine whether the files are hard links or symbolic links.
- Prove your conclusion using inode information.
- Document the exact command used.

### Constraints
- Do not rely on file content comparison.
- Use filesystem metadata only.

---

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ls -li /tmp/file1 /tmp/file2 # Same inode → hard link. Different inodes with -> → symbolic link.
  ```
</details>

---

## Task 6 – Permission Correction Scenario

A script located at `/opt/scripts/backup.sh` fails to execute.

### Requirements
- Identify why the script cannot be executed.
- Fix the permissions so:
  - Owner can read, write, and execute.
  - Group can read and execute.
  - Others have no access.

### Constraints
- Ownership must remain unchanged.
- Use **numeric permission notation**.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  chmod 750 /opt/scripts/backup.sh
  ```
  **Check**

  ```bash
  ls -l /opt/scripts/backup.sh
  ```
</details>

---

## Task 7 – Archive Creation for Incident Response

You must collect configuration evidence before a system change.

### Requirements
- Create a compressed archive containing:
  - `/etc/passwd`
  - `/etc/group`
  - `/etc/fstab`
- Archive name: `/root/system_baseline.tar.gz`

### Constraints
- Preserve file permissions.
- Do not include unnecessary files.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  tar -cpzf /root/system_baseline.tar.gz /etc/passwd /etc/group /etc/fstab
  ```
  **Check**

  ```bash
  tar -tzvf /root/system_baseline.tar.gz
  ```
</details>

---

## Task 8 – Documentation-Driven Troubleshooting

You need to understand how system-wide environment variables are loaded.

### Requirements
- Identify the correct man page section describing login shells.
- Locate the configuration file responsible for global environment variables.
- Provide the exact command used to find this information.

### Constraints
- Use `man`, `info`, or documentation under `/usr/share/doc`.
- No internet access.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  man man ; man 5 login ; man 5 profile
  ```
</details>

---

## Task 9 – Pipeline Efficiency Challenge

Generate a list of **unique usernames** currently logged into the system.

### Requirements
- Output must contain one username per line.
- No duplicate entries.
- Use a single pipeline.

### Constraints
- Do not use temporary files.
- Do not use scripting languages.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  who | cut -d " " -f 1 | sort | uniq
  ```
</details>

---

## Task 10 – Advanced Text Filtering (Regex / awk)

The Security team requires a list of all system accounts that are allowed to log in.

### Requirements

- Filter /etc/passwd to display accounts with:
  - UID between 0 and 999
  - - A valid login shell

- Exclude any account using:
    - /sbin/nologin
    - /bin/false

- Save the resulting list to:
    - /root/login_accounts.txt

### Constraints

- Use a single grep or awk command if possible.
- Do not include header lines or extra formatting.
- Do not modify /etc/passwd.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  awk -F: '$3 >= 0 && $3 <= 999 && $7 !~ /(nologin|false)/ {print $1}' /etc/passwd > /root/login_accounts.txt
  ```
  **Check**

  ```bash
  cat /root/login_accounts.txt
  ```
</details>

---

## Task 11 – Secure Remote Operations (SSH)

You need to verify connectivity to a remote system while maintaining strict security controls.

### Requirements

- Access the remote server at:

    10.0.2.15

  as user:

    admin

- Execute the uptime command without opening an interactive shell.

- Append the output to the local file:

  /tmp/remote_checks.log

### Constraints

- Do not use password authentication (assume SSH keys are configured).
- The command must execute and exit immediately.
- Do not open an interactive SSH session.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ssh admin@10.0.2.15 uptime >> /tmp/remote_checks.log  
  ```
  **Check**

  ```bash
  cat /tmp/remote_checks.log
  ```
</details>

---

## Task 12 – Command Location Without which

You need to identify the full filesystem path of a command.

### Requirements

- Identify the full path of the tar command.

## Constraints

- Use built-in shell tools only.
- Do not use the which command.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  type -a tar
  ```
</details>

## Task 13 – Safe File Inspection (No Modification)

You need to inspect recent log activity without modifying any files.

### Requirements

- Display the last 20 lines of /var/log/messages.
- Do not edit or alter the file.

### Constraints

- Use command-line tools only.
- No interactive editors.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  tail -n 20 /var/log/messages
  ```
</details>