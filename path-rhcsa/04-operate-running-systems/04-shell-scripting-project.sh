#!/bin/bash

# 1. Execution Security
if [[ $EUID -ne 0 ]]; then
   echo "--------------------------------------------------------"
   echo "ERROR: This script requires administrative privileges."
   echo "Please run it using: sudo $0"
   echo "--------------------------------------------------------"
   exit 1
fi

# Working Directory & Packaging Rules
DIR_DATE=$(date +%F) 
WORKDIR="/baseline/operate-running-systems_$DIR_DATE"
ARCHIVE="/baseline/operate-running-systems_$DIR_DATE.tar.gz"

# create a directory
mkdir -p "$WORKDIR"


# Phase 1 – Resource Pressure Mitigation

# 1.1. Capture Top CPU Consumers
touch  $WORKDIR/top_cpu_processes.txt
{
  echo -e "====== TimesTamp: $(date) ======\n"
  echo -e "====== Highest CPU-consuming processes ======\n"
  ps -eo pid,ppid,user,ni,pcpu,pmem,comm --sort=-pcpu | head -4
} >> $WORKDIR/top_cpu_processes.txt

# 1.2. Controlled Cleanup of test-user Processes
{
  echo -e "====== TimesTamp: $(date) ======\n"
  echo -e "===== Controlled Cleanup of test-user Processes ======\n"
  echo -e "===== Initial process list ======\n"
  ps -eo pid,ppid,ni,pcpu,pmem,comm --sort=-pcpu -U test-user
  
  if id test-user &>/dev/null; then
    for pid in $(pgrep -u test-user); do
      cmd=$(ps -p "$pid" -o comm=)
      if [[ "$cmd" != "bash" && "$cmd" != "sshd" ]]; then
          kill -15 "$pid"
      fi
    done
  else
    echo "User test-user does not exist"
  fi

  echo -e "\n===== Final process list ======\n"
  ps -eo pid,ppid,ni,pcpu,pmem,comm --sort=-pcpu -U test-user
} >> $WORKDIR/test_user_processes.txt

# Phase 2 – Boot Configuration & Log Compliance

# 2.1. Correct Default Target
echo -e "====== TimesTamp: $(date) ======\n"
systemctl set-default multi-user.target
{
  echo -e "===== Default target ======\n"
  systemctl get-default
} >> $WORKDIR/boot_target.txt

# 2.2. Configure Persistent Journaling
#mkdir -p /var/log/journal
#systemd-tmpfiles --create --prefix /var/log/journal

#Edit:
#/etc/systemd/journald.conf
# Storage=persistent
# SystemMaxUse=500M
# MaxRetentionSec=30day

{
  echo -e "====== TimesTamp: $(date) ======\n"
  echo -e "===== Persistent Journaling ======\n"
  systemctl restart systemd-journald
  systemctl show systemd-journald

  journalctl --disk-usage
  journalctl --verify
} >> $WORKDIR/journald_config.txt


# Phase 3 – Security Review & Service Recovery

# 3.1 Extract Failed sudo Attempts
{
  echo -e "====== TimesTamp: $(date) ======\n"
  echo -e "===== Failed sudo Attempts ======\n"

  if id malware-bot &>/dev/null; then
    journalctl -b _UID=$(id -u malware-bot) _COMM=sudo -o short-iso | grep -i failed
  else 
    echo "User malware-bot does not exist"
  fi
} >> $WORKDIR/sudo_failed_malware_bot.txt

#3.2. Recover Failed sync Units
{
  echo -e "====== TimesTamp: $(date) ======\n"
  echo -e "===== Systemd units in failed state ======\n"
  systemctl list-units --state=failed
  echo -e "\n===== Systemd units with word sync======\n"
  systemctl list-units --type=service --state=failed --no-legend | grep -iE "sync"
} >> $WORKDIR/failed_units_initial.txt

for svc in $(systemctl --failed --type=service --no-legend \
  | grep -iE "sync" | awk '{print $1}'); do
    systemctl restart "$svc"
done

{
  echo -e "====== TimesTamp: $(date) ======\n"
  echo -e "===== Verify final state ======\n"
  systemctl list-units --type=service --state=failed
} >> $WORKDIR/failed_units_final.txt

# Phase 4 – Resilient Log Transfer

# 4.1. This backup must
# rsync -avzP /var/log/remote_backups/ operator@backup-vault:/backup/ >> $WORKDIR/rsync_command_used.txt

# 4.2. Global Evidence Files
{
  echo -e "====== TimesTamp: $(date) ======\n"
  echo -e "====== Global Evidence Files ======\n"
  echo -e "====== Hostname ======\n"
  hostnamectl
  echo -e "\n====== Kernel version ======\n"
  uname -r
  echo -e "\n====== Uptime ======\n"
  uptime
  echo -e "\n====== Execution date ======\n"
  date
  echo -e "\n====== Executing user ======\n"
  who
  echo -e "\n====== Execution_log ======\n"
  journalctl --user $(id -u) 
} >> $WORKDIR/final_report.txt 2>&1

# Archive
tar -czf "$ARCHIVE" -C /baseline "operate-running-systems_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "Operate-running-systems REPORT successfully created at $ARCHIVE"

exit 0