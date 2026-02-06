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
WORKDIR="/baseline/section02_$DIR_DATE"
ARCHIVE="/baseline/software_birth_certificate_$DIR_DATE.tar.gz"
SAP_RPM_URL=$(dnf repoquery --location compat-openssl11 | head -n 1)

# create a directory

mkdir -p "$WORKDIR"

# Phase 1: Repository Trust & Compliance

{
  echo -e "====== Phase 1: Repository Trust & Compliance ====== \n"
  
  echo -e "====== List of all configured repositories (enabled and disabled) ====== \n"
  dnf repolist --all
  
  echo -e "\n ====== Enabled repositories ====== \n"
  dnf repolist
  
  echo -e "\n ====== Repository configuration files ====== \n"
  ls -lh /etc/yum.repos.d
} >> "$WORKDIR/repos_audit.txt"

dnf clean all
dnf makecache

# Phase 2: Performance Monitoring & Integrity

dnf install htop -y
dnf install nload -y

{
  echo -e "====== Phase 2: Performance Monitoring & Integrity ====== \n"
  
  echo -e "====== Integrity of the htop package ====== \n"
  rpm -V htop
  
  echo -e "\n ====== Document the package architecture and list all files installed by nload ====== \n"
  rpm -qi nload
  rpm -ql nload
}>> "$WORKDIR/packages_audit.txt"

# Phase 3: Security Traceability

{
  echo -e "====== Phase 3: Security Traceability ====== \n"
  
  echo -e "====== RPM package that owns the /usr/bin/passwd binary ====== \n"
  rpm -qf /usr/bin/passwd 
   
  echo -e "\n ====== List all documentation files (man pages) provided by the bash package ====== \n"
  rpm -qd bash
}>> "$WORKDIR/packages_audit.txt"


# Phase 4: Middleware Runtime (AppStream Modules)

{
  echo -e "====== Phase 4: Middleware Runtime (AppStream Modules) ====== \n"
  
  echo -e "====== List all available nodejs module streams ====== \n"
  dnf module list nodejs
}>>"$WORKDIR/modules_audit.txt"

dnf module reset nodejs -y
dnf module enable nodejs:20 -y
dnf module install nodejs:20 -y

{
  echo -e "====== Phase 4: Middleware Runtime (AppStream Modules) ====== \n"
  
  echo -e "====== Exact version of the node binary ====== \n"
  rpm -qi nodejs
}>>"$WORKDIR/node_version.txt"

# Phase 5: Sandboxed Visualizers (Flatpak)

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub org.gimp.GIMP -y

{
  echo -e "====== Phase 5: Sandboxed Visualizers (Flatpak) ====== \n"
  
  echo -e "====== Runtimes automatically installed as dependencies ====== \n"
  flatpak list --runtime --columns=ref,name,version,arch,branch,origin 
}> "$WORKDIR/flatpak_audit.txt"

flatpak uninstall org.gimp.GIMP -y

flatpak uninstall --unused -y

# Phase 6: Rollback Strategy & Troubleshooting

{
  echo -e "====== Phase 6: Rollback Strategy & Troubleshooting ====== \n"
  
  echo -e "====== Currently installed openssh version ====== \n"
  rpm -qi openssh 
  
  echo -e "\n ====== Repositories for all available versions of the package ====== \n"
  dnf list openssh --showduplicates --all
  
  echo -e "\n ====== Write down the exact command required to perform a version downgrade ====== \n"
  echo -e "dnf downgrade openssh -y \n"
}> "$WORKDIR/versions_audit.txt"

dnf clean all
dnf makecache

# Phase 7: Third-Party SAP Components (Direct Deployment)

curl -L -o "$WORKDIR/compat-openssl11.rpm" "$SAP_RPM_URL"
dnf install -y "$WORKDIR/compat-openssl11.rpm"

{
echo -e "====== Installation status and package details compat-openssl11.rpm ====== \n"
rpm -qpi "$WORKDIR/compat-openssl11.rpm"  
}>> "$WORKDIR/packages_audit.txt"

# Phase 8: Software Birth Certificate (Final Audit)

{
  echo -e "====== Phase 8: Software Birth Certificate ====== \n"
  
  echo -e "====== Enabled repositories ====== \n"
  dnf repolist --enabled
  
  echo -e "\n ====== Status of the Node.js module stream ====== \n"
  dnf module list nodejs
  
  echo -e "====== List the 20 most recently installed RPMs ====== \n"
  rpm -qa --last | head -n 20
}>>"$WORKDIR/software_audit.txt"

# Archive
tar -czf "$ARCHIVE" -C /baseline "section02_$DIR_DATE"
chmod 600 "$ARCHIVE"

# Cleanup
rm -rf "$WORKDIR"

echo "Software Birth Certificate successfully created at $ARCHIVE"