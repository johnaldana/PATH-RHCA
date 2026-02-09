# 03 – Create Simple Shell Scripts
## Project 03 – The Midnight Guardian: Advanced System Health & Security Monitor (Shell Scripting)

You are the **Junior SysAdmin** on night duty at **TechNova Solutions.**

The production Linux server shows signs of serious instability:

- Brute-force attacks
  
- CPU and memory spikes
  
- Disk filling unexpectedly
  
- Services behaving strangely even after log cleanup
  
- Your Senior suspects deleted-but-open files, disk I/O saturation, and memory pressure.

Your senior left you a task: initialize a secure monitoring workspace, audit critical system files, and generate a system health report to ensure the server doesn't crash while everyone is sleeping.

You must collect hard operational evidence, not guesses.

## Project Objective

Create a Bash script named:

**03-shell-scripting-project.sh**

The script must patrol the system, collect security and performance diagnostics, store them in a structured way, and package everything for escalation.

---

## Working Directory & Packaging Rules

- Work inside /baseline

- Create a directory:

  ```bash
  /baseline/guardian_YYYY-MM-DD/
  ```

- Store all generated artifacts inside this directory

- Compress it into:

  ```bash
  guardian_YYYY-MM-DD.tar.gz
  ```
---

## Functional Requirements

### 1. Execution Security

- Script must run only as root
- If not root:

  ```bash
  ERROR: This script must be run as root
  ```

- Exit with status code 1

---

### 2. Argument Validation

- Script must receive one argument:

    - A valid log directory path

- If missing or invalid:

  ```bash
  Usage: ./03-shell-scripting-project.sh /var/log
  ```
- Exit with non-zero status

---

### 3. Mandatory Report File
 
All collected data must be appended to:

  ```bash
  /baseline/guardian-YYYY-MM-DD/guardian_report.txt
  ```

Rules:

- Use >>
  
- Include:
  
    - Timestamp
  
    - Clear section headers
  
    - Visual separators

---

### 4. Process Load Monitoring

The report must include:

- Total number of running processes
  
- If process count > 200:

    ```bash
    ALERT: HIGH LOAD detected
    ```
---

### 5. Top Resource Consumers

Include two separate sections:

- Top 10 processes by CPU usage

- Top 10 processes by Memory usage

- Each entry must show:

    - PID

    - User

    - CPU %

    - MEM %

    - Command

---

### 6. Logged-in Users Audit (Security)

The report must include:

- All currently logged-in users

- Terminal (TTY)

- Login time

- Source host (if remote)

- Label clearly:

  ```bash
  --- Active User Sessions ---
  ```

---

### 7. Network Connectivity Check

- Test connectivity to:
  
  ```bash
  8.8.8.8
  ```
- Log connection status

- If failed:

  ```bash
  WARNING: Network connectivity issue detected
  ```

---

### 8. Basic System Health Snapshot

The report must capture:

- System uptime

- Disk usage (df)

- Directory disk usage (du, limited output)

- Memory usage (free)
  
---

### 9. Log Directory Audit

- Scan provided log directory

- Identify .log files

- If a .log file is larger than 100 MB:

  ```bash
  CRITICAL: <filename> needs rotation
  ```
---

### 10. Large Log Evidence File

- Create:

  ```bash
  large_logs.txt
  ```

Rules:

- Stored inside /baseline/guardian_YYYY-MM-DD/

- Must contain only filenames of .log files > 100 MB

- Append mode only

---

### 11. Deleted but Open Files (Disk Leak Detection)

The script must detect files that have been deleted but are still open by processes.

**Requirements:**

- Do not list files, PIDs, or sizes

- Report only the total number of such files

- Clearly label the section
  
- If one or more are found:

    - Log a warning

    - Include the total count

- If none are found:

    - Explicitly state that the system is clean

---

### 12. Disk & Memory Pressure Monitoring

**a. Memory & CPU activity**

- Output of:

  ```bash
  vmstat 1
  ```

- Include at least two sample in the report

**b. Disk I/O health**

- Output of:

  ```
  iostat -xz 1
  ```

- Include at least two sample in the report

---

### 13. Historical Metrics via SAR

- Include system historical metrics if sysstat package is installed:

    - Queue length: sar -q

    - CPU usage: sar -u

    - Memory usage: sar -r

- Append output to guardian_report.txt

- Label each section clearly:

  ```bash
  --- Historical Queue Metrics (sar -q) ---
  --- Historical CPU Usage (sar -u) ---
  --- Historical Memory Usage (sar -r) ---
  ```
- These metrics help reconstruct the state of the system during an incident

---

### 14. Packaging

After all checks:

- Compress:

  ```bash
  /baseline/guardian-YYYY-MM-DD/
  ```

- Into:
  
  ```
  guardian-YYYY-MM-DD.tar.gz
  ```

---

### 15. Exit Status

Exit 0 on successful completion