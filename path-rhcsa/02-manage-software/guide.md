# 02 - Manage Software

This guide covers software management on **RHEL 9**, focusing on RPM-based systems and Flatpak.  
All tasks are expected to be performed from the **command line only**, as required in the RHCSA exam.

---

## 2.1. RPM Repositories Management

RHEL systems use **DNF** to manage software via RPM repositories.

### List configured repositories

```bash
dnf repolist                 # shows only enabled repositories
dnf repolist --all           # shows all repositories (enabled + disabled)
```
### Repository configuration files

Repositories are defined in:

```bash
/etc/yum.repos.d/*.repo
```
Each .repo file contains sections like:

```bash
[baseos]
name=BaseOS
baseurl=http://mirror.example.com/rhel9/BaseOS/
enabled=1
gpgcheck=1
```
```bash
dnf clean all && dnf makecache    # refresh metadata after changing repos
```
- baseurl or mirrorlist: repository source
- enabled: 1 = active, 0 = disabled
- gpgcheck: enforce package signature verification

### Enable or disable a repository
```bash
dnf config-manager --enablerepo=baseos
dnf config-manager --disablerepo=appstream
```
## 2.2. Installing and Removing RPM Packages

```bash
dnf install nginx vim git -y
dnf install @development-tools           # install a package group
dnf install python3.11                   # explicit package

dnf remove nginx vim -y
dnf autoremove                           # remove unneeded dependencies

dnf update
dnf update kernel

# Reinstall (useful when files are corrupted)
dnf reinstall firewalld -y
```

## 2.3. RPM Package Verification and Queries

### Basic rpm -q options (most used)

```bash
rpm -qa                    # list all installed packages
rpm -qi <package>          # show package information
rpm -qf <file>             # which package owns this file?
rpm -ql <package>          # list all files installed by the package
rpm -qd <package>          # list only documentation files
rpm -qlv <package>         # list files + permissions, size, timestamps
rpm -V  <package>          # verify integrity (checksums, permissions, etc.)
rpm -Va                    # verify ALL installed packages
```

## 2.4. Modules

Modules are a feature of AppStream that allows the same software to have multiple versions/streams available at the same time on the system.

**Most important module commands**

```Bash
# 1. List all available modules
dnf module list

# 2. List modules for a specific software
dnf module list nodejs
dnf module list postgresql
dnf module list php

# 3. Show only currently enabled modules
dnf module list --enabled

# 4. Reset a module (remove any enabled stream, back to default state)
dnf module reset nodejs
dnf module reset postgresql

# 5. Enable a specific stream/version
dnf module enable nodejs:20
dnf module enable postgresql:15
dnf module enable php:8.2

# 6. Install the main package using the currently enabled stream
dnf install nodejs
dnf install postgresql-server
dnf install php

# 7. Enable + install in one command (most common in exams)
dnf module install nodejs:20
dnf module install php:8.3

# 8. Get detailed information about a module stream
dnf module info nodejs:20
dnf module info postgresql:15
```

## 2.5. Flatpak Overview

Flatpak is used for user-space desktop applications, isolated from the base OS.

Flatpak is not a replacement for RPM and is typically used for GUI applications.

**Key Concepts**

- Remotes = repositories (Flathub is the most important)
- Application ID format: org.gnome.gedit, com.visualstudio.code, org.videolan.VLC
- Runtimes = shared dependencies (freedesktop, gnome, kde)

```Bash  
# Make sure flatpak is installed
dnf install flatpak -y

# List configured remotes
flatpak remotes
flatpak remote-ls --show-details

# Add Flathub (almost always required in the exam)
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Search applications
flatpak search gimp
flatpak search code

# Install applications
flatpak install flathub org.gimp.GIMP -y
flatpak install flathub com.visualstudio.code -y

# List installed apps and runtimes
flatpak list
flatpak list --app
flatpak list --runtime

# Run an application
flatpak run org.gimp.GIMP

# Update everything
flatpak update -y

# Remove application + clean unused runtimes
flatpak uninstall org.gimp.GIMP
flatpak uninstall --unused
```

