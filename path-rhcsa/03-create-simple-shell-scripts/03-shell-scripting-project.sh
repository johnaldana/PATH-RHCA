#!/bin/bash

# 1. Execution Security
if [[ $EUID -ne 0 ]]; then
   echo "--------------------------------------------------------"
   echo "ERROR: This script requires administrative privileges."
   echo "Please run it using: sudo $0"
   echo "--------------------------------------------------------"
   exit 1
fi


# 2. Argument Validation
  LOG_DIR=$1

  if [ -z "$LOG_DIR" ] || [ ! -d "$LOG_DIR" ]; then
    echo "Error: Please provide a valid directory."
    echo "Usage: ./03-shell-scripting-project.sh /var/log"
    exit 2
  fi

# Working Directory & Packaging Rules
DIR_DATE=$(date +%F) 
WORKDIR="/baseline/guardian_$DIR_DATE"
ARCHIVE="/baseline/guardian_$DIR_DATE.tar.gz"

# create a directory
mkdir -p "$WORKDIR"


# 3. Mandatory Report File
touch  $WORKDIR/guardian_report.txt
echo -e "====== GUARDIAN REPORT ======" >> $WORKDIR/guardian_report.txt


# 4. Process Load Monitoring
{
  echo -e "\n====== 1. Process Load Monitoring ======"
  NUMBER_PROCESS=$(ps aux | wc -l)
  echo -e "\nTotal number of running processes: $NUMBER_PROCESS"
  if [[ $NUMBER_PROCESS -gt 200 ]];then
    echo -e "\n==============================="
    echo -e "   ALERT: HIGH LOAD detected   "
    echo -e "==============================="
  fi
} >> $WORKDIR/guardian_report.txt


# 5. Top Resource Consumers
{
  echo -e "\n====== 2. Top Resource Consumers ======"
  echo -e "\n====== Top 10 processes by CPU usage ======"
  ps aux --sort=-%cpu | head
  echo -e "\n====== Top 10 processes by Memory usage ======"
  ps aux --sort=-%mem | head
} >> $WORKDIR/guardian_report.txt


# 6. Logged-in Users Audit (Security)
{
  echo -e "\n====== 3. Logged-in Users Audit ======"
  echo -e "\n--- Active User Sessions ---"
  who
} >> $WORKDIR/guardian_report.txt


# 7. Network Connectivity Check
{
  echo -e "\n====== 4. Network Connectivity Check ======"
  if ping -c 3 -W 5 8.8.8.8 &> /dev/null; then
    echo -e "\nConnection Status: OK"
  else
    echo -e "\n==========================================="
    echo -e "Connection Status: FAILED"
    echo -e "WARNING: Network connectivity issue detected"
    echo -e "============================================="
  fi
} >> $WORKDIR/guardian_report.txt


# 8. Basic System Health Snapshot
{
  echo -e "\n====== 5. Basic System Health Snapshot ======"
  echo -e "\nSystem uptime: "
  uptime
  echo -e "\nDisk usage (df): "
  df -h
  echo -e "\nDirectory disk usage (du, limited output): "
  du -sh "$LOG_DIR"
  echo -e "\nMemory usage (free): "
  free -h
} >> $WORKDIR/guardian_report.txt


# 9. Log Directory Audit and 10. Large Log Evidence File
{
  echo -e "\n====== 6. Log Directory Audit ======" 
  # Loop through the directory provided as the first argument
  for file in "$LOG_DIR"/*.log; do
    # Ensure the file exists (prevents errors if no .log files are found)
    [[ -e "$file" ]] || continue

    # Get file size in bytes
    FILE_SIZE=$(stat -c%s "$file")

    # Check if size is greater than 100MB
    if [[ $FILE_SIZE -gt 104857600 ]]; then
        # Requirement 9: Log to the main report
        echo "CRITICAL: $(basename "$file") needs rotation (Size: $((FILE_SIZE / 1024 / 1024)) MB)"
        
        # Requirement 10: Append filename ONLY to large_logs.txt
        basename "$file" >> "$WORKDIR/large_logs.txt"
    fi
done
} >> $WORKDIR/guardian_report.txt


# 11. Deleted but Open Files (Disk Leak Detection)
{
  echo -e "\n====== 7. Deleted but Open Files ======"
  
  DELETED_COUNT=$(lsof -nP +L1 2>/dev/null | tail -n +2 | wc -l)

  if [[ "$DELETED_COUNT" -gt 0 ]]; then
    echo -e "\n========================================="
    echo -e "WARNING: Deleted files still open detected"
    echo -e "Open deleted files count: $DELETED_COUNT"
    echo -e "==========================================="
  else
    echo "No deleted but open files detected."
  fi

} >> $WORKDIR/guardian_report.txt


# 12. Disk & Memory Pressure Monitoring
{
  echo -e "\n====== 8. Disk & Memory Pressure Monitoring ======"
  echo -e "\n====== Memory & CPU activity ======"
  vmstat 1 2
  echo -e "\n====== Disk I/O health ======"
  iostat -xz 1 2
} >> $WORKDIR/guardian_report.txt


# 13. Historical Metrics via SAR
{
  echo -e "\n====== 9. Historical Metrics via SAR ======"
  echo -e "\n--- Historical Queue Metrics (sar -q) ---"
  sar -q 1 1
  echo -e "\n--- Historical CPU Usage (sar -u) ---"
  sar -u 1 1
  echo -e "\n--- Historical Memory Usage (sar -r) ---"
  sar -r 1 1
} >> $WORKDIR/guardian_report.txt

# Archive
tar -czf "$ARCHIVE" -C /baseline "guardian_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "GUARDIAN REPORT successfully created at $ARCHIVE"

exit 0