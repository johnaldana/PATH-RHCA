# 08 - Manage Basic Networking 
## Project 08 - Network Bastion Operation 

TechLogistics Corp is migrating its inventory server to a new network segment. As a **Linux SysAdmin**, your task is to ensure that the server is accessible only by authorized systems, maintain internal communication, enable dual-stack networking, secure services, and document all changes. 

--- 

## Phase 1 – Network Deployment (Dual-Stack) 

The inventory server must be connected to the corporate network using both IPv4 and IPv6. Any previous network profile may cause conflicts, so a clean connection must be created. 

**Tasks:** 

- Identify the physical network interface: `enp1s0`.
- Remove any previous connection profiles.
- Create a new connection named `Prod-Network` with: 
  
  - **Primary IPv4:** `172.16.50.10/24`
  - **Secondary IPv4 (Legacy):** `192.168.1.100/24`
  - **IPv4 Gateway:** `172.16.50.1`
  - **Static IPv6:** `2001:db8:acad::10/64`
  - **IPv6 Gateway:** `2001:db8:acad::1`

- Configure DNS servers: `8.8.8.8, 1.1.1.1`
- Configure automatic search domain: `techlogistics.local`
- Set persistent hostname: `srv-inv-01.techlogistics.local`
- Verify connectivity and resolution. 

--- 

## Phase 2 – Security & Firewall Restrictions 

The server hosts critical services: an API on port `8080/tcp` and a logging service on port `514/udp`. Only authorized hosts should access these services, and all other IPv4 traffic must be restricted. 

**Tasks:** 

- Assign the interface `enp1s0` to the `public` zone. 
- Open standard services: `http` and `https`. 
- Open application ports: `8080/tcp` and `514/udp`. 
- Restrict SSH access (port `22/tcp`) to admin subnet `172.16.100.0/24`. Reject SSH from any other source. 
- Apply IPv4 hardening: drop all incoming traffic except for the loopback interface. 
- Verify firewall rules and connectivity. 

--- 

## Phase 3 – Persistence & Boot Optimization

The server must remain fully functional after reboots. Boot completion should only be considered when the network is fully online, which is critical for NFS or cluster services. 

**Tasks:** 

- Enable the `NetworkManager-wait-online.service`. 
- Ensure the network connection starts automatically on boot. 
- Verify service status. 

--- 

## Phase 4 – Legacy Application Support 

Some legacy applications require a secondary IPv4 address. Adding it must not disrupt the primary IP or existing connectivity. 

**Tasks:** 

- Add secondary IP: `192.168.1.101/24` on the same interface. 
- Ensure the connection remains active without downtime. 
- Verify network configuration. 

--- 

## Phase 5 – Load Balancer & Health Checks 

The server participates in a load-balanced cluster. Health checks are performed by the external load balancer on port `9000/tcp`. 

**Tasks:** 

- Open port `9000/tcp` in the `public` zone. 
- Ensure the rule persists after reloads and reboots. 
- Verify connectivity from the load balancer. 

--- 

## Phase 6 – Malicious IP Mitigation 

Suspicious activity has been detected from IP `203.0.113.88`. 

**Tasks:** 

- Block the malicious IP immediately across all zones. 
- Ensure the block persists after reboot. 
- Verify that the IP is effectively blocked. 

--- 

## Phase 7 – IPv6 Hardening 

The server must be secured in IPv6 while still allowing essential network communication for neighbor discovery and diagnostics. 

**Tasks:** 
- Set default IPv6 policy to DROP in the `public` zone. 
- Allow only the following ICMPv6 types:
   
  - `echo-request` 
  - `neighbor-solicitation` 
  - `neighbor-advertisement` 
  - `router-advertisement`
   
- Preserve all other existing rules. 
- Verify IPv6 firewall configuration. 

--- 

## Phase 8 – Logging & Archival 

As a SysAdmin, all changes must be documented for audit and learning purposes. 

**Tasks:** 

-Create a project folder inside `/baseline`: 

   `/baseline/08-manage-basic-networing_<YYYY-MM-DD>/`

- Save all verification outputs, including: 

    - IP addresses and routes 
    - NetworkManager connections 
    - Firewall rules 
    - DNS resolution tests 

- Compress the folder for archival or submission. 
- Ensure all commands requiring elevated privileges are run as root (`EUID=0`).