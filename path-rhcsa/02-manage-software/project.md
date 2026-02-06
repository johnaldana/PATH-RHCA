# Section 02 – Final Project

## Project Phoenix: Software Infrastructure Baseline

The **SAP Application Team** is scheduled to start the NetWeaver installation tomorrow. As the Junior Admin, you must deliver a **"Software Birth Certificate"** that proves the server meets all vendor requirements. We need to ensure that the middleware has the correct **Node.js** version, that legacy encryption is available for the SAP installer.

### Working Rules ##

- **Workspace:** All artifacts must be stored in /baseline/section02_$(date +%F)/.

- **Permissions:** Use sudo for all administrative tasks.

- **Integrity:** No manual editing of configuration files in /etc/yum.repos.d/.

---

### Phase 1: Repository Trust & Compliance

The security team has reported that some servers in the dev environment were pulling packages from unauthorized mirrors. For this production node, we must guarantee that only **Phoenix Tech Official Repositories** are active.

- **Task 1.1:** Generate a complete list of all configured repositories (enabled and disabled).

- **Task 1.2:** Filter and identify only the currently enabled repositories.

- **Task 1.3:** Record the physical location of the repository configuration files for the audit trail.

- **Task 1.4:** Refresh the metadata cache to ensure the system is ready for the upcoming installations.

- **Output:** repos_audit.txt

---

### Phase 2: Performance Monitoring & Integrity

During the SAP migration, the Operations Center needs to monitor system resources in real-time. We will use **htop** and **nload.** However, we must prove these binaries are genuine and haven't been tampered with.

- **Task 2.1:** Install the htop and nload packages.

- **Task 2.2:** Verify the integrity of the htop package against the RPM database.

- **Task 2.3:** Document the package architecture and list all files installed by nload.

- **Output:** packages_audit.txt

---

### Phase 3: Security Traceability

A security auditor is questioning the origin of core system utilities. We need to demonstrate that we can trace any binary back to its original RPM provider.

- **Task 3.1:** Find the specific RPM package that owns the /usr/bin/passwd binary.

- **Task 3.2:** List all documentation files (man pages) provided by the bash package to ensure local support is available.

- **Output:** Append findings to packages_audit.txt.

---

### Phase 4: Middleware Runtime (AppStream Modules)

The SAP engine is hardcoded to work with **Node.js version 20.** The default system version might cause a application startup failures or installer validations errors.

- **Task 4.1:** List all available nodejs module streams in the **AppStream repository.**

- **Task 4.2:** Reset the module configuration to ensure a clean state.

- **Task 4.3:** Enable and install the Node.js 20 stream.

- **Task 4.4:** Capture the exact version of the node binary as proof for the developers.

- **Output:** modules_audit.txt and node_version.txt.

---

### Phase 5: Sandboxed Visualizers (Flatpak)

Analysts require GIMP to analyze graphical log exports. To maintain a "Lean Server" policy, we will not install graphical libraries in the base OS; we will use a sandbox.

- **Task 5.1:** Add the Flathub remote repository.

- **Task 5.2:** Install the **org.gimp.GIMP** application.

- **Task 5.3:** Identify all runtimes automatically installed as dependencies.

- **Task 5.4:** Uninstall the application and remove all orphaned runtimes to reclaim disk space.

- **Output:** flatpak_audit.txt

---

### Phase 6: Rollback Strategy & Troubleshooting

The openssh service is critical for remote access. If a future update breaks compatibility, we need a documented recovery plan.

- **Task 6.1:** Identify the currently installed **openssh version.**

- **Task 6.2:** Query the repositories for all available versions of the package.

- **Task 6.3:** Write down the exact command required to perform a version downgrade.

- **Task 6.4:** Perform a full DNF cache cleanup to resolve potential metadata corruption.

- **Output:** versions_audit.txt

---

### Phase 7: Third-Party SAP Components (Direct Deployment)

The SAP installer requires legacy encryption libraries. The vendor has provided the **compat-openssl11 package** for immediate deployment. This ensures SAPInst can run using legacy cryptographic required by older SAP components.

- **Task 7.1:** Download the **compat-openssl11 package** to your workspace

- **Task 7.2:** Install it directly as a **Local RPM.**

- **Output:** Append the installation status and package details to packages_audit.txt.

---

### Phase 8: Software Birth Certificate (Final Audit)

The server is ready for handoff. We need a single authoritative document that summarizes the software environment.

**Task 8.1:** Generate a report showing all enabled repositories.

**Task 8.2:** Include the status of the Node.js module stream.

**Task 8.3:** List the 20 most recently installed RPMs to confirm the SAP components were deployed correctly.

**Output:** software_audit.txt

---

### Final Packaging & Delivery

Once all phases are complete, compress the entire /baseline/section02_$(date +%F)/ directory into a **.tar.gz file.** Set the permissions to **600** for security.