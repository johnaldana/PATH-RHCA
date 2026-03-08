#!/bin/bash

# Execution Security
if [[ $EUID -ne 0 ]]; then
   echo "--------------------------------------------------------"
   echo "ERROR: This script requires administrative privileges."
   echo "Please run it using: sudo $0"
   echo "--------------------------------------------------------"
   exit 1
fi

set -euo pipefail

# Working Directory & Packaging Rules
DIR_DATE=$(date +%F) 
WORKDIR="/baseline/08-manage-basic-networking_$DIR_DATE"
ARCHIVE="/baseline/08-manage-basic-networking_$DIR_DATE.tar.gz"
LOG_FILE="$WORKDIR/project08-log.txt"

# create a directory
mkdir -p "$WORKDIR"

# Phase 1 – Network Deployment (Dual-Stack) 
nmcli con show >> "$LOG_FILE"

nmcli -t -f NAME,DEVICE con show | grep enp1s0 | cut -d: -f1 | while read con; do
    nmcli con delete "$con"
done

nmcli con add con-name Prod-Network ifname enp1s0 type ethernet \
  ipv4.method manual ipv4.addresses 172.16.50.10/24 \
  ipv4.gateway 172.16.50.1 ipv4.dns "8.8.8.8 1.1.1.1" \
  ipv6.method manual ipv6.addresses 2001:db8:acad::10/64 \
  ipv6.gateway 2001:db8:acad::1 \
  ipv4.dns-search "techlogistics.local" \
  connection.autoconnect yes

nmcli con up Prod-Network 

nmcli con mod Prod-Network +ipv4.addresses 192.168.1.100/24
nmcli con up Prod-Network

hostnamectl set-hostname srv-inv-01.techlogistics.local

if dig google.com &> /dev/null; then
    echo "Connection SUCCESSFUL."
else
    echo "Connection FAILED."
fi


# Phase 2 – Security & Firewall Restrictions
systemctl enable --now firewalld

firewall-cmd --zone=public --change-interface=enp1s0 --permanent

firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent

firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=514/udp --permanent

firewall-cmd --add-rich-rule='rule family="ipv4" source address="172.16.100.0/24" service name="ssh" accept' --permanent

firewall-cmd --zone=public --set-target=DROP --permanent

firewall-cmd --reload
firewall-cmd --list-all

# Phase 3 – Persistence & Boot Optimization

systemctl enable --now NetworkManager-wait-online.service 
systemctl is-enabled NetworkManager-wait-online.service

# Phase 4 – Legacy Application Support
nmcli con mod Prod-Network +ipv4.addresses 192.168.1.101/24
nmcli con up Prod-Network

ip a s

# Phase 5 – Load Balancer & Health Checks
firewall-cmd --zone=public --add-port=9000/tcp --permanent
firewall-cmd --reload

firewall-cmd --list-all
ss -tuln | grep 9000 || true

# Phase 6 – Malicious IP Mitigation 
firewall-cmd --add-rich-rule='rule family="ipv4" source address="203.0.113.88" drop'

firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="203.0.113.88" drop'
   
firewall-cmd --reload

firewall-cmd --list-rich-rules  

# Phase 7 – IPv6 Hardening

firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" icmp-type name="echo-request" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" icmp-type name="neighbor-solicitation" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" icmp-type name="neighbor-advertisement" accept'
firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" icmp-type name="router-advertisement" accept'

firewall-cmd --reload

firewall-cmd --zone=public --list-all
firewall-cmd --zone=public --list-rich-rules


# Phase 8 – Logging & Archival 
{
  echo -e "====== Timestamp: $(date) ======\n"
  echo "====== Documentation ======\n"
  echo "\n====== IP addresses ======\n"
  ip a s
  ip -6 a s
  echo "\n====== Routes  ======\n"
  ip route
  ip -6 route
  echo "\n====== NetworkManager connections ======\n"
  nmcli con show
  echo "\n====== Firewall rules ======\n"
  firewall-cmd --list-all
  firewall-cmd --list-rich-rules
  echo "\n====== DNS resolution tests ======\n"
  if dig google.com &> /dev/null; then
    echo "Connection SUCCESSFUL."
  else
    echo "Connection FAILED."
  fi
  
} > "$LOG_FILE"

# Archive
tar -czf "$ARCHIVE" -C /baseline "08-manage-basic-networking_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "08 Manage Basic Networking REPORT successfully created at $ARCHIVE"

exit 0