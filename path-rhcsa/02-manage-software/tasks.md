# Section 02 – Tasks: Manage Software 
**RHCSA – RHEL 9**

All tasks must be completed using the command line only.
Assume you are working on a **headless RHEL 9 server.**

## Task 01 – Repository Inspection & Validation

A system administrator suspects that a server is using incorrect or disabled repositories, which may cause installation failures during maintenance.

### Requirements

- List all configured repositories, including disabled ones.
- Identify which repositories are currently enabled.
- Verify where repository configuration files are stored on the system.
- Refresh the repository metadata cache.

### Constraints

- Do not edit any repository files.
- Do not install or remove packages.
- Use only DNF-related commands.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf repolist --all
  dnf repolist 
  dnf repolist -v 
  dnf clean all
  dnf makecache
  ```
</details>

---

## Task 02 – Enable a Disabled Repository

A required package is not available because its repository is disabled.

### Requirements

- Identify a disabled repository on the system.
- Enable that repository using DNF tools (not manual file editing).
- Confirm that the repository is now enabled.

### Constraints

- Do not modify .repo files directly with an editor.
- Use dnf config-manager.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf repolist --disabled
  dnf config-manager --enablerepo=repo_id
  dnf repolist -v 
  ```
</details>

---

## Task 03 – Install, Verify, and Inspect an RPM Package 

You are asked to install a package and confirm its integrity and contents before it is used in production.

### Requirements

- Install the tree package.
- Display detailed information about the installed package.
- List all files installed by the package.
- Verify the package integrity to ensure no files were modified.

### Constraints

- Use both dnf and rpm commands.
- Do not reinstall the package unless required.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf install tree
  rpm -qi tree
  rpm -ql tree
  rpm -V tree
  ```
</details>

---

## Task 04 – Identify Package Ownership

During troubleshooting, you find a binary on the system and need to know which package owns it.

### Requirements

- Identify which RPM package owns /usr/bin/passwd.
- Display basic information about that package.

### Constraints

- Do not search online.
- Use RPM queries only.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  rpm -qf /usr/bin/passwd
  rpm -qi passwd
  ```
  **Check**

</details>

---

## Task 05 – Package Removal and Cleanup

A temporary tool was installed for debugging and must now be removed cleanly.

### Requirements

- Remove the tree package.
- Ensure that no unused dependencies remain after removal.

### Constraints

- Use DNF cleanup features.
- Do not remove unrelated packages.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf remove tree -y
  dnf autoremove -y
  ```
</details>

---

## Task 06 – Working with Package Documentation

You need to review local documentation provided by installed packages.

### Requirements

- Locate documentation files installed by the bash package.
- List only documentation-related files.
- Display detailed file information (permissions, size, timestamp).

### Constraints

- Use RPM query commands only.
- Do not browse directories manually.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  rpm -qd bash
  rpm -ql bash
  rpm -qdv bash
  ```
</details>

---

## Task 07 – Module Streams Inspection

An application requires a specific version of a language runtime that is managed via AppStream modules.

### Requirements

- List all available module streams for nodejs.
- Identify which stream (if any) is currently enabled.
- Display detailed information for one available stream.

### Constraints

- Do not enable or reset any module yet.
- Use module inspection commands only.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf module list nodejs
  dnf module info nodejs
  dnf module list --enabled
  ```
</details>

---

## Task 08 – Module Enable and Install

A development team requires Node.js version 20 for their application.

### Requirements

- Reset any existing nodejs module configuration.
- Enable the nodejs:20 stream.
- Install Node.js using the enabled module stream.
- Confirm the installed version.

### Constraints

- Use module-aware DNF commands.
- Do not install Node.js using non-module RPMs.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf module reset nodejs
  dnf module enable nodejs:20
  dnf module install nodejs:20
  dnf module list nodejs
  ```
</details>

---

## Task 09 – Flatpak Repository Configuration

A desk top application must be installed using Flatpak, but no Flatpak repositories are configured.

### Requirements

- Verify whether Flatpak is installed.
- List existing Flatpak remotes.
- Add the Flathub repository if it is not already present.
- Confirm the repository was added successfully.

### Constraints

- Do not install any Flatpak applications yet.
- Use official Flathub repository URL (*https://dl.flathub.org/repo/flathub.flatpakrepo*).

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf install flatpak -y
  flatpak remote-ls
  flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak remote-ls | grep flathub
  ```
</details>

---

## Task 10 – Flatpak Application and Runtime Inspection

Before installing a Flatpak application, you want to understand which runtimes are involved.

### Requirements

- Search for the GIMP Flatpak application.
- Install org.gimp.GIMP.
- List all installed Flatpak applications.
- List all installed Flatpak runtimes.
- Identify which runtime GIMP depends on.

### Constraints

- Do not remove any runtimes.
- Use Flatpak inspection commands.
  
<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  flatpak search gimp
  flatpak install flathub org.gimp.GIMP
  flatpak list --app
  flatpak info --show-runtime org.gimp.GIMP
  ```
</details>

---

## Task 11 – Flatpak Cleanup

A Flatpak application is no longer needed and must be removed cleanly.

### Requirements

- Remove the GIMP Flatpak application.
- Remove any unused runtimes left behind.
- Verify that no unused runtimes remain.

### Constraints

- Do not remove active runtimes.
- Use Flatpak cleanup commands only.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  flatpak uninstall org.gimp.GIMP
  flatpak uninstall --unused
  flatpak list --runtime
  ```
</details>

---

## Task 12 – Troubleshooting Scenario

A user reports that dnf install fails due to corrupted metadata.

### Requirements

- Clean all DNF caches.
- Rebuild the metadata cache.
- Verify that repositories are accessible after cleanup.

### Constraints

- Do not reboot the system.
- Do not reinstall DNF.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf clean all
  dnf makecache
  dnf repolist
  ```
</details>

---

## Task 13 – Package Downgrade / Version Awareness

A package was updated and caused compatibility issues.

### Requirements:

- Identify the installed version of a package.
- List available versions from repositories.
- Explain (command-only) how you would downgrade it.
  (no ejecutar downgrade, solo demostrar dominio)

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  rpm -q package
  rpm -qi package
  dnf list --showduplicates package
  dnf downgrade package
  ```
</details>

---

## Task 14 – Local RPM Installation

A vendor provides a local RPM file custom-agent-1.2.3-1.x86_64.rpm.

### Requirements:

- Install a package from a local .rpm file.
- Verify its installation.
- Identify which files were installed.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  dnf install ./custom-agent-1.2.3-1.x86_64.rpm
  rpm -q custom-agent
  rpm -ql custom-agent
  ```
</details>

---

## Task 15 – Mixed Environment Audit

You must audit a system before handoff.

### Requirements:

- List all enabled RPM repositories.
- List all enabled module streams.
- List all installed Flatpak applications.
- Save all outputs to /root/software_audit.txt.
  
<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
 {
  echo "=== ENABLED REPOSITORIES ==="
  dnf repolist

  echo -e "\n=== MODULES ==="
  dnf module list --enabled

  echo -e "\n=== FLATPAK APPLICATIONS ==="
  flatpak list --app
 } > /root/software_audit.txt
```
</details>

---