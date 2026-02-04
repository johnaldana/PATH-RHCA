## Section 01 Project: System Baseline & Diagnostic Tool

### Scenario

A new server has been deployed to host a mission-critical SAP workload. Before handing it over to the application team, the **Lead Admin** requires a **System Baseline Report.** This report will serve as a "snapshot" of the system's healthy state, ensuring that any future configuration drift or performance issues can be compared against this initial baseline.

### Objective

Your goal is to create a Bash script that automates the collection of this diagnostic data, archives it into a single secure file, and cleans up the workspace.

### Technical Specifications

  **1. Privilege & Environment Control**

    - Root Validation: The script must verify the $EUID variable. If not running as root, it must abort with the message: "ERROR: Administrative privileges required."

    - Dedicated Workspace: All operations must occur within the /baseline root directory.

    - Working Directory: Create a temporary sub-folder named data_$(date +%F) to stage the reports.

  **2. Diagnostic Reports (with Headers)**

    Generate the following text files inside the working directory, each starting with its respective header:
    
    sys_info.txt

    - Header: --- System Identity & Resources ---

    - Data: hostnamectl, uname -r, uptime, and free -h.

    security_audit.txt

    - Header: --- Currently Logged Users ---

    - Data: List of unique usernames currently logged into the system (who + filters).

    logs_snapshot.txt

    - Header: --- Last 50 System Errors (Journal) ---

    - Data: The last 50 error-level entries from journalctl.

  **3. Configuration Baseline**
    
    Copy the following critical files using the -p flag to preserve metadata:

    - /etc/fstab (Filesystem mounts)

    - /etc/passwd (User database)

    - /etc/hosts (Network resolution)

  **4. Archiving and Hardening**

    - Compression: Create a .tar.gz archive named report_$(date +%F).tar.gz inside /baseline.

    - Cleanup: Automatically remove the temporary data_$(date +%F) folder after compression.

    - Security: Set the archive permissions to 600 so only the root user can access the baseline data.

### Success Criteria

- Running the script with sudo generates /baseline/report_YYYY-MM-DD.tar.gz.

- The /baseline directory is clean (only the archive remains).

- All internal reports contain the required headers and data points.