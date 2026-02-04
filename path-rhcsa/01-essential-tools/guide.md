# 01 - Understand and use essential tools

## Operational Guide – RHCSA (RHEL 9)

This section covers the fundamental tools and commands that you are expected to master 100% for the RHCSA exam and any real-world production environment running Red Hat Enterprise Linux.

## Main Objective

To be able to move fluently within the command line, locate information quickly, manipulate files and text, and work efficiently on remote servers—all without a graphical interface.

---

## 1.1. Shell Access and Basic Command Execution

- **Login** via console or SSH.
  - ssh user@server  
  
- **Understand common prompts:**
  - `$` → Normal user.
  - `#` → Root (Superuser).
  - `[user@hostname directory]$`
  
- **Switch users:**    
  - su - username
    ```bash
    su   # switches user but keeps the current environment
    su - # loads the full target user environment (HOME, PATH, variables)
    ```
- **Command Syntax**
  - command [options] [arguments]
  - Examples:
    ```bash
        ls -l /var/log
    ```
- **Common mistakes:**
  - Mixing options and arguments in the wrong order
  - Forgetting to quote paths with spaces


### Essential Information Commands:

```bash
whoami          # Who am I logged in as?
pwd             # Where am I? (Print Working Directory)
hostname        # Server name
date            # System date and time
uptime          # How long has the system been up and current load average
clear           # Clear the terminal screen
history         # View the history of executed commands
!123            # Repeat command number 123 from history 
```

## 1.2. Input/Output Redirection and Pipelines

| **Operator** | **Meaning** | **Example** | **Typical Use Case** |
| :--- | :--- | :--- | :--- |
| >	| Redirect output (overwrite) | ls -l &nbsp; > &nbsp; list.txt | Save output to a new file |
| >> | Redirect output (append) | echo "end" &nbsp; >> &nbsp; list.txt | Add logs to the end of a file |
| 2> | Redirect errors (stderr) | ls /root &nbsp; 2> &nbsp; errors.log | Separate error messages |
| 2>&1 | Errors to standard output | command &nbsp; > &nbsp; log 2>&1 | Capture everything in one file |
| \| | Pipe | ls -l &nbsp;  \| &nbsp;  wc -l  | Pass the output of one command as input to another to chain tasks |
| <	| Redirect input | sort &nbsp; < &nbsp; names.txt | Use file content as command input |

### Production Tips:

```bash
command &> full_output.log      # Both stdout + stderr to one file (Modern syntax)
command > /dev/null 2>&1        # "Black hole": Discard all output (common in crontab)
```
## 1.3. Text Searching and Filtering – grep

```bash
grep "error" /var/log/messages              # Search for an exact word
grep -i "error" /var/log/*                  # Ignore case (-i)
grep -r "password" /etc/                    # Recursive search in directories (-r)
grep -v "DEBUG" app.log                     # Exclude lines (invert match -v)
grep "^[a-z]" /etc/passwd                   # Regex: Lines starting with a lowercase letter
grep -E "[0-9]{1,3}\.[0-9]{1,3}" access.log # Extended regex (-E) for IPs
```
### Common patterns:
- '^' start of line
- '$' end of line
- '.' any character
- '*' zero or more

### Powerful Combinations:

```bash
grep "error" /var/log/messages | wc -l       # Count how many times an error appears
journalctl -u sshd | grep -i "fail"          # View SSH authentication failures
ps aux | grep [m]ysql                        # Filter processes without showing the grep process itself
```

## 1.4. Archiving and Compression
  - Create archive:
    ```bash
    tar -cvf backup.tar /etc
    ```
  - Create compressed archive:
    ```bash
    tar -czvf backup.tar.gz /etc
    tar -cjvf backup.tar.bz2 /etc
    ```
  - Extract:
    ```bash
    tar -xvf backup.tar
    tar -xzvf backup.tar.gz
    ```

## 1.5. Working with Files and Directories

```bash
touch file.txt                  # Create an empty file or update timestamp
mkdir -p /long/path/subdir      # Create parent directories if they don't exist (-p)
cp -r source destination        # Copy directories recursively (-r)
mv file /new/path/              # Move or rename
rm -rf /dangerous/path/         # CAUTION! Recursive and forced deletion
ln -s /real/path link           # Symbolic link (Soft link)
ln /real/path link              # Hard link
```

### Key Difference: Links

| **Feature** | **Hard link** | **Softlink (symlink)** |
| :--- | :--- | :--- |
| Across Filesystems? | No | Yes |
| If original is deleted... | Link still works | Link breaks (Dangling) | 
| Inode | Shares the same inode | Has its own inode | 
| Command |ln | ln -s |

## 1.6. Basic Permissions (ugo / rwx)

```bash
ls -l                           # View detailed permissions
chmod u+x script.sh             # User (u): add execute (x)
chmod g+w file.txt              # Group (g): add write (w)
chmod o-r /etc/shadow           # Others (o): remove read (r)
chmod 750 /opt/app              # rwxr-x--- (Octal notation)
```
### Common Permissions:
    - 644 (rw-r--r--): Standard files.
    - 755 (rwxr-xr-x): Scripts and public directories.
    - 600 (rw-------): Sensitive files (e.g., SSH private keys).
  
### Change ownership:
    - chown user:group file
  
## 1.7. System Documentation

```bash
man ls                      # Command manual
man 5 passwd                # Section 5: Configuration file formats
man -k network              # Search man pages
info coreutils              # Detailed documentation
whatis chmod                # One-line description
apropos "copy file"         # Search commands by keyword or function
```

### Critical System Files Reference

| **CategoryFile** | **Path** | **Description** | **Why it matters** |
| :--- | :--- | :--- | :--- |
| Users | /etc/passwd | User account details (UID, Shell) | Basic identity management. | 
| Security | /etc/shadow | Encrypted passwords & aging | Compliance & Password policies. | 
| Privileges | /etc/sudoers | Sudo access rules | Critical for root-level access control. | 
| Groups | /etc/group | Group definitions | Managing permissions for app owners. | 
| Defaults | /etc/login.defs | Shadow suite configuration | Defines min/max password days. | 
| Environment | /etc/profile | System-wide shell variables | Setting global paths ($PATH). | 
| User Shell | ~/.bashrc | Per-user aliases & functions | Personalizing the CLI experience. |
| Skeleton | /etc/skel/ | Template for new users | Standardizing home dirs for new admins. |
| Limits | /etc/security/limits.conf | Resource limits (nofile, nproc) | Critical for SAP HANA & DB performance. | 
| Kernel | /etc/sysctl.conf | Kernel runtime parameters | Tuning network and memory management. |
| Logging | /etc/systemd/journald.conf | Systemd journal settings | Configuring log persistence (Required for RHCSA). | 
| Network | /etc/hosts | Local DNS lookup table | Essential when DNS is down. | 
| DNS | /etc/resolv.conf | DNS resolver config | Tells the system which nameservers to use. |
| SSH | /etc/ssh/sshd_config | SSH Server configuration | Hardening remote access (Security). | 
| Storage | /etc/fstab | Static filesystem mounts | The #1 file for system persistence. | 
| Boot | /etc/default/grub | GRUB bootloader parameters | Modifying boot behavior (e.g., console speed). |