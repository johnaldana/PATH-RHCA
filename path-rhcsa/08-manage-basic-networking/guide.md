# 08 - Manage Basic Networking

This section focuses on configuring network interfaces, ensuring persistent connectivity, and securing the system using the built-in firewall.

**Objectives Covered:**
- Configure IPv4 and IPv6 addresses
- Configure hostname resolution
- Configure network services to start automatically at boot
- Restrict network access using **firewalld** and **firewall-cmd**

**Key Tool:** NetworkManager (via `nmcli` and `nmtui`), hostnamectl, systemctl, firewall-cmd, ss, ip.

**Deprecated:** Old `ifcfg-*` files and `network` service (do not use them in RHEL 9+)

---

## 8.1. Basic Network Inspection Commands

```bash
# Show all network devices and status
nmcli device status
nmcli device show

# Show all connection profiles
nmcli connection show
nmcli connection show --active

# Show detailed configuration of a connection
nmcli connection show "Connection-Name" 

# Text-based UI
nmtui
```
---

## 8.2. Configure IPv4 and IPv6 Addresses 

### Using nmcli

**Static IPv4 example (on interface enp1s0):**

```bash
# Add/modify a static IPv4 connection
nmcli con add con-name mylan ifname enp1s0 type ethernet \
  ipv4.method manual ipv4.addresses 192.168.10.50/24 \
  ipv4.gateway 192.168.10.1 ipv4.dns "8.8.8.8 8.8.4.4"

# Or modify existing connection
nmcli con mod mylan ipv4.method manual \
  ipv4.addresses 192.168.10.55/24 ipv4.gateway 192.168.10.1

# Activate it
nmcli con up mylan
```

**DHCP IPv4:**
```bash
nmcli con mod mylan ipv4.method auto
nmcli con up mylan
```

**Static IPv6 example:**

```bash
nmcli con mod mylan ipv6.method manual \
  ipv6.addresses "2001:db8:cafe:1::55/64" \
  ipv6.gateway "2001:db8:cafe:1::1"
nmcli con up mylan

# Or disable IPv6 completely on interface
nmcli con mod mylan ipv6.method disabled
```

**Quick one-liner to add secondary IP:**

```bash
nmcli con mod mylan +ipv4.addresses 192.168.10.77/24
```
---

## 8.3. Configure Hostname Resolution

**Set system hostname**

```bash
# Show current hostname
hostname
hostnamectl

# Set permanent hostname
hostnamectl set-hostname server1.example.com
```
**Local hostname resolution (/etc/hosts)**

```bash
# Quick local name → IP mapping
echo "192.168.10.50  server1.example.com server1" >> /etc/hosts
echo "2001:db8::50   server1.example.com server1" >> /etc/hosts
```

**DNS configuration (via NetworkManager)**

```bash
# Set DNS servers for a connection
nmcli con mod mylan ipv4.dns "8.8.8.8 1.1.1.1"
nmcli con up mylan

# Verify DNS resolution
nmcli con show mylan | grep dns
host server1.example.com
dig server1.example.com
```
---

## 8.4. Configure Network Services to Start Automatically at Boot

NetworkManager handles this by default for connections.

```bash
# Make sure NetworkManager starts on boot
systemctl enable NetworkManager
systemctl is-enabled NetworkManager

# Enable a specific connection profile to auto-start
nmcli con mod mylan connection.autoconnect yes

# Or using nmtui → Edit connection → check "Automatically connect"
```
---

## 8.5. Restrict Network Access using firewalld & firewall-cmd

firewalld is the default firewall manager in RHEL 9/10.

**Basic firewall-cmd commands**

```bash
# Check status
systemctl status firewalld
firewall-cmd --state

# Enable and start 
systemctl enable --now firewalld

# List everything
firewall-cmd --list-all
firewall-cmd --get-active-zones
firewall-cmd --get-zones
firewall-cmd --get-default-zone

# Set default zone
firewall-cmd --set-default-zone=internal
firewall-cmd --permanent --set-default-zone=public
```
**Common zone operations**

```bash
# Allow SSH permanently 
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Allow HTTP + HTTPS
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https

# Allow specific port (e.g. custom app on 8080/tcp)
firewall-cmd --permanent --add-port=8080/tcp

# Remove rule
firewall-cmd --permanent --remove-service=ftp
firewall-cmd --permanent --remove-port=9000/udp

# Assign interface to a zone
firewall-cmd --permanent --zone=internal --change-interface=enp1s0
firewall-cmd --reload

# Rich rules
firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.10.0/24" service name="http" accept'

# Blocks all incoming and outgoing traffic immediately
firewall-cmd --panic-on

# Deactivate panic mode
firewall-cmd --panic-off
```

**Quick reload (always needed after --permanent changes)**

```bash
firewall-cmd --reload          # Apply permanent changes
firewall-cmd --complete-reload # Nuclear option (drops all connections)
```
---

## 8.6. Verification Commands

**Always verify your configuration:**

```bash
ip a
ip route
ss -tuln
nmcli connection show
firewall-cmd --list-all
ping 8.8.8.8
```

