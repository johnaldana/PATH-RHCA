# 08 – Manage Basic Networking - Tasks 
**RHEL - RHCSA**


## Tasks 1 – New Web Server Deployment (IPv4 + IPv6)

A new web server must be deployed with static IPv4 and IPv6 configuration. The configuration must persist after reboot. Manual file editing is not allowed.

### You must:

- Configure static IPv4:

    IP: `192.168.10.45/24`

    Gateway: `192.168.10.1`

    DNS: `8.8.8.8, 1.1.1.1`

    Use nmcli only.

- Ensure the configuration persists after reboot.

- Add static IPv6:

    IP: `2001:db8:cafe:face::45/64`

    Gateway: `2001:db8:cafe:face::1`

- Verify:

    `ip a`

    `ip route`

    `ping`

    `ping -6`

    `nmcli connection show`

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  nmcli devices

  nmcli con add type ethernet \
    con-name static \
    ipv4.method manual \
    ifname enp1s0 \
    ipv4.addresses 192.168.10.45/24 \
    ipv4.gateway 192.168.10.1 \
    ipv4.dns "8.8.8.8 1.1.1.1" \
    ipv6.method manual \
    ipv6.addresses 2001:db8:cafe:face::45/64 \
    ipv6.gateway 2001:db8:cafe:face::1 \
    connection.autoconnect yes

  nmcli con up static

  ip a

  ip route
  ip -6 route

  ping -c 4 192.168.10.1
  ping -6 -c 4 2001:db8:cafe:face::1

  nmcli connection show static
  ```

</details>

---

## Tasks 2 – DNS & Hostname Resolution Failure

Developer reports that server **app-prod-03** cannot resolve internal hostnames. Only direct IP connections work.

### You must:

- Set persistent hostname to:

    `app-prod-03.company.local`

- Configure:

    Search domain: `company.local`

    DNS servers: `10.200.0.53, 10.200.0.54`

- Ensure changes persist after reboot.

- Verify using:

    `hostnamectl`

    `hostname -f`

    `nmcli dev show`

    `dig`

    `getent hosts`

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  hostnamectl set-hostname app-prod-03.company.local
  
  nmcli device status
  nmcli connection show

  nmcli con mod CONN_NAME \
  ipv4.dns "10.200.0.53 10.200.0.54" \
  ipv4.dns-search "company.local"

  nmcli con mod CONN_NAME connection.autoconnect yes

  nmcli con up CONN_NAME

  hostnamectl
  hostname -f
  nmcli dev show | grep DNS
  dig app-prod-03.company.local
  getent hosts app-prod-03.company.local
  ```
</details>

---

## Tasks 3 – Kubernetes Worker Renaming

A Kubernetes worker node must be renamed from:

`worker-old-07`

to:

`k8s-worker-az1-07`

### You must:

- Set persistent hostname.

- Set pretty hostname.

- Ensure the prompt reflects the new hostname.

- Verify using:

    `hostnamectl`

    `hostname -f`

    `echo $HOSTNAME`


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  hostnamectl set-hostname k8s-worker-az1-07

  hostnamectl set-hostname "K8s Worker AZ1 Node 07" --pretty
  
  exec bash 

  hostnamectl
  hostname -f
  echo $HOSTNAME
  ```
</details>

---

## Tasks 4 – Monitoring Agent Firewall Rule

A monitoring agent listens on TCP port `5514`.

### You must:

- Allow port `5514/tcp` permanently.

- Apply rule in the `public` zone.

- Ensure rule survives:

    `firewall-cmd --reload`

    `Reboot`

- Verify using:

    `firewall-cmd --list-all`

    `ss -tuln`


<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  firewall-cmd --get-active-zones

  firewall-cmd --zone=public --add-port=5514/tcp --permanent
  firewall-cmd --reload

  reboot

  firewall-cmd --list-all --zone=public
  ss -tuln
  ```
</details>

---

## Tasks 5 – Restrictive SSH Access (Office Only)

Temporary test server must allow SSH only from subnet:

`172.24.80.0/20`

All other SSH access must be blocked.

### You must:

- Use appropriate zone or rich rule.

- Permit SSH only from office subnet.

- Ensure SSH from public internet is blocked.

- Verify using:

    `firewall-cmd --list-all`

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ZONE=$(firewall-cmd --get-active-zones | head -n 1)
  
  firewall-cmd --zone=$ZONE --permanent --add-rich-rule='rule family="ipv4" source address="172.24.80.0/20" service name="ssh" accept'

  firewall-cmd  --zone=$ZONE --permanent --remove-service=ssh
  
  firewall-cmd --reload
  firewall-cmd --zone=$ZONE --list-all
  ```
</details>

---

## Tasks 6 – IPv6-Only DMZ Migration

Server must drop all incoming IPv4 traffic except loopback traffic.

### You must:

- Block all IPv4 INPUT traffic.

- Allow:

    Established/related connections

    Loopback interface

- Preserve IPv6 functionality.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ZONE=$(firewall-cmd --get-active-zones | head -n 1)
  
  firewall-cmd --permanent --zone=$ZONE --add-rich-rule='rule family="ipv4" source address="127.0.0.1" accept'

  firewall-cmd --permanent --zone=$ZONE --add-rich-rule='rule family="ipv4" drop'
  
  firewall-cmd --reload
  firewall-cmd --zone=$ZONE --list-all
  ```
</details>

---

## Tasks 7 – Add Secondary IPv4 (No Downtime)

Legacy app requires additional IPv4:

`172.31.77.200/24`

**Must:**

- Not remove primary IP

- Not cause downtime

### You must:

- Add secondary IP using nmcli.

- Do not bring interface down.

- Verify using:

    `ip a`

    `nmcli connection show`

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  nmcli con mod CONN_NAME +ipv4.addresses 172.31.77.200/24
  nmcli con up CONN_NAME

  ip a
  nmcli connection show CONN_NAME 
  ```
</details>

---

## Tasks 8 – DNS Infrastructure Change

Internal DNS servers changed after cloud migration.

New internal DNS servers:

`10.50.10.10`
`10.50.10.11`

### You must:

- Update DNS servers via NetworkManager.

- Replace old DNS servers.

- Add fallback nameserver:

    `1.0.0.1`

- Ensure `/etc/resolv.conf` is not manually edited.

- Ensure DHCP does not override DNS settings.

- Verify persistence after reboot.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  nmcli con show
  
  nmcli con mod CONN_NAME ipv4.dns "10.50.10.10 10.50.10.11 1.0.0.1"
  nmcli con mod CONN_NAME ipv4.ignore-auto-dns yes
  nmcli con up CONN_NAME

  reboot

  nmcli connection show CONN_NAME | grep ipv4.dns
  cat /etc/resolv.conf
  resolvectl status
  ```
</details>

---

## Tasks 9 – Pod Network Firewall Restriction

Host must allow ports:

`8080/tcp`
`8443/tcp`

Only from subnet:

`10.244.0.0/16`

### You must:

- Create firewalld rich rule.

- Restrict to pod subnet only.

- Verify rule using:

`firewall-cmd --list-rich-rules`

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.244.0.0/16" port=8080/tcp accept'

  firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="10.244.0.0/16" port=8443/tcp  accept'
   
  firewall-cmd --reload

  firewall-cmd --list-rich-rules  
  ```
</details>

---

## Tasks 10 – NetworkManager Wait Online

System must consider boot complete only after network is fully online (important for NFS or cluster services).

### You must:

- Enable:

    `NetworkManager-wait-online.service`

- Verify:

    `systemctl is-enabled`

    `systemctl status`

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  systemctl enable --now NetworkManager-wait-online.service

  systemctl status NetworkManager-wait-online.service
  ```
</details>

---

## Tasks 11 – IPv6 Firewall Hardening (Public Server)

Harden IPv6 firewall configuration.

### You must:

- Set default IPv6 policy to DROP in public zone.

- Allow essential ICMPv6:

    echo-request

    neighbor-solicitation

    neighbor-advertisement

    router-advertisement

    Preserve existing rules.

- Verify using:

    `firewall-cmd --list-all`

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  ZONE=$(firewall-cmd --get-active-zones | grep public -A1 | head -n1)

  firewall-cmd --permanent --zone=public --set-target=DROP

  firewall-cmd --permanent --zone=public --add-icmp-block-inversion=no
  
  firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" icmp-type name="echo-request" accept'
  firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" icmp-type name="neighbor-solicitation" accept'
  firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" icmp-type name="neighbor-advertisement" accept'
  firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv6" icmp-type name="router-advertisement" accept'

  firewall-cmd --reload

  firewall-cmd --zone=public --list-all
  firewall-cmd --zone=public --list-rich-rules  
  ```
</details>

---

## Tasks 12 – Load Balancer Health Check Failure

External load balancer fails health-check on port `9000/tcp`.

### You must:

- Allow `9000/tcp` in internal zone.

- Reload firewall.

- Verify using:

    `firewall-cmd --list-all --zone=internal`

    `ss -tuln`

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  firewall-cmd --zone=internal --add-port=9000/tcp --permanent
  firewall-cmd --reload

  firewall-cmd --list-all --zone=internal
  ss -tuln | grep 9000
  ```
</details>

---

## Tasks 13 – Immediate Malicious IP Block

Block malicious IP:

`203.0.113.88`

Across all zones immediately.

### You must:

- Add high-priority direct DROP rule.

- Ensure rule is permanent.

- Verify rule listing.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #Immediate lock
  firewall-cmd --add-rich-rule='rule family="ipv4" source address="203.0.113.88" drop'

  firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="203.0.113.88" drop'
   
  firewall-cmd --reload

  firewall-cmd --list-rich-rules  
  ```
</details>

---

## Tasks 14 – Recover Lost Network After Reboot

Production server lost network connectivity after reboot.

Interface:

`enp3s0`

Required configuration:

- IP: `10.160.20.85/23`
- Gateway: `10.160.20.1`
- Connection name: "System enp3s0"
- Autoconnect: `yes`

### You must:

- Recreate connection profile using a full nmcli con add command.

- Enable autoconnect.

- Bring connection up.

- Verify connectivity and routing.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  nmcli devices

  nmcli con add type ethernet \
    con-name "System enp3s0" \
    ipv4.method manual \
    ifname enp3s0 \
    ipv4.addresses 10.160.20.85/23 \
    ipv4.gateway 10.160.20.1 \
    ipv4.dns "8.8.8.8 1.1.1.1" \
    ipv6.method ignore \
    connection.autoconnect yes

  nmcli con up "System enp3s0"

  ip a

  ip route
 
  ping -c 4 10.160.20.1
  
  nmcli connection show "System enp3s0"
  ```

</details>
