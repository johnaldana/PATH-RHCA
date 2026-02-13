# 04 – Operate Running Systems
## Project 04 - Major Incident – Post-Maintenance Stabilization

**Server: app-prod-sync**

app-prod-sync is a production node responsible for application data synchronization between internal services and external partners.

The server was rebooted during a scheduled maintenance window to apply security patches and dependency updates.

Within minutes of returning to production:

- Monitoring detected sustained high CPU usage.

- Memory consumption exceeded historical baseline.

- Several synchronization units appeared in failed state.

- The system booted into graphical mode unexpectedly.

- Logs were found to be non-persistent across reboots (compliance risk).

- The Security Operations Center (SOC) flagged suspicious sudo attempts.

- Infrastructure requested an immediate off-site backup of accumulated logs.

The system must remain online.
No additional reboot is allowed.
All actions must be traceable.

You are required to stabilize the system, preserve forensic evidence, enforce persistence where required, and deliver a structured evidence package.

---

## Execution Model

All work must be performed through a single script:

```bash
/baseline/04-shell-scripting-project.sh
```

**The script must:**

- Run only with root privileges.

- Create the working directory:

```bash
/baseline/operate-running-systems_YYYY-MM-DD
```

- Store all evidence files directly inside this directory.

- Generate a structured technical report.

- Compress the directory as:

```bash
operate-running-systems_YYYY_MM_DD.tar.gz
```

At completion, /baseline must contain only:

```bash
04-shell-scripting-project.sh
operate-running-systems_YYYY_MM_DD.tar.gz
```

## Phase 1 – Resource Pressure Mitigation

High CPU and memory pressure in production can:

- Degrade synchronization latency

- Cause queue backlogs

- Trigger cascading failures in dependent systems

Before making changes, you must capture the current state as operational evidence.

### Required Actions

**1.1. Capture Top CPU Consumers**

Identify the three highest CPU-consuming processes, including:

- PID
  
- PPID

- USER

- NICE

- %CPU

- %MEM

- COMMAND

**Evidence file:**

```bash
top_cpu_processes.txt
```

This establishes the performance baseline at time of intervention.

**1.2. Controlled Cleanup of test-user Processes**

User test-user is consuming memory via background processes.

**You must:**

Terminate all non-essential processes using SIGTERM.

Only terminate processes owned by test-user excluding:

- "sshd"
- "bash"
- "login shells"

It must contain:

- Initial process list

- Signal sent

- Final list

Preserve:

- sshd session

- active bash shell

This avoids disrupting network connectivity while freeing memory.

**Evidence files:**

```bash
test_user_processes.txt
```

---

### Phase 2 – Boot Configuration & Log Compliance

The server booted into graphical mode, which is inappropriate for a headless production system.

Additionally, journald logs are not persistent, violating retention policy and audit requirements.


### Required Actions

**2.1. Correct Default Target**

- Set default target to multi-user.target.

**Evidence files:**

```bash
boot_target.txt
```

**2.2. Configure Persistent Journaling**

Journald must be configured to:

- Store logs persistently.

- Limit total disk usage to 500MB.

- Retain logs for a maximum of 30 days.

- Changes must be applied without reboot.

- Edit:
  
  ```bash
  /etc/systemd/journald.conf
  ```
- Validate effective configuration using:
  
  ```bash
  systemctl restart systemd-journald
  systemctl show systemd-journald
  ```

**Evidence files:**

journald_config.txt

---

## Phase 3 – Security Review & Service Recovery

The SOC reported unusual activity involving malware-bot.

Simultaneously, synchronization units in failed state may disrupt data integrity.

Both issues must be addressed carefully and documented.

### Required Actions

**3.1 Extract Failed sudo Attempts**

- Filter journal logs to extract only:

- Failed sudo attempts

- User: malware-bot

- From the current boot session

**Evidence file:**

```bash
sudo_failed_malware_bot.txt
```

**3.2. Recover Failed sync Units**

- Identify all systemd units in failed state.

- Filter those containing the word sync.

- Restart them using a loop.

- Verify final state.

**Evidence files:**

```bash
failed_units_initial.txt
failed_units_final.txt
```

---

## Phase 4 – Resilient Log Transfer

Infrastructure requires an external backup of accumulated logs in case further instability occurs.

**4.1. This backup must:**

- Preserve permissions, timestamps, and symlinks.

- Use compression.

- Be resumable if interrupted.

- Display progress and transfer rate.
  
- The command must ensure partial transfers are kept and resumed.
  
- **Source:**

```bash
  /var/log/remote_backups/
```

- **Destination:**

```bash
operator@backup-vault:/backup/
```

**Evidence files:**

```bash
rsync_command_used.txt
```

**4.2. Global Evidence Files**

In addition to phase-specific evidence, the working directory must include:

- **Must contain:**

    - Hostname

    - Kernel version

    - Uptime

    - Execution date

    - Executing user
    
    ```bash
    final_report.txt
    ```

## Final Deliverable

**The script must:**

- Create the working directory.

- Generate all required evidence files.

- Perform all corrective actions.

- Produce the technical report.

- Compress everything into:

  ```bash
  operate-running-systems_YYYY_MM_DD.tar.gz
  ```

 - Only the script and the compressed archive must remain in /baseline