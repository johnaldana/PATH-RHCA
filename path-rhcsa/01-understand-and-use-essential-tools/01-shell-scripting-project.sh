#!/bin/bash

# Check if the script is running as root
if [[ $EUID -ne 0 ]]; then
   echo "--------------------------------------------------------"
   echo "ERROR: This script requires administrative privileges."
   echo "Please run it using: sudo $0"
   echo "--------------------------------------------------------"
   exit 1
fi

#variables
DIR_DATE=$(date +%F) 
WORKDIR="/baseline/data_$DIR_DATE"
ARCHIVE="/baseline/baseline_report_$DIR_DATE.tar.gz"

# create a directory
mkdir -p "$WORKDIR"

# System Identity & Resources
{
  echo "--- System Identity & Resources ---"
  hostnamectl
  echo
  echo "Kernel:"
  uname -r
  echo
  echo "Uptime:"
  uptime
  echo
  echo "Memory:"
  free -h
} >> "$WORKDIR/system_info.txt"

# Security Audit
{
  echo "--- Currently Logged Users ---"
  who | cut -d " " -f 1 | sort | uniq
} >> "$WORKDIR/security_audit.txt"

# Logs
{
  echo "--- Last 50 System Errors (Journal) ---"
  journalctl -p err -n 50
} >> "$WORKDIR/logs_snapshot.txt" 2>/dev/null

# Critical files
cp -p /etc/fstab /etc/passwd /etc/hosts "$WORKDIR/"

# Archive
tar -czf "$ARCHIVE" -C /baseline "data_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "Baseline report successfully created at $ARCHIVE"