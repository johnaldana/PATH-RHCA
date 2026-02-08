# 03 - Create Simple Shell Scripting - Tasks 
**RHCSA – RHEL 9**

## Task 1: User Onboarding Greeting

The HR department wants a personalized welcome message for new developers when they open their first terminal.

### Requirement:

-  Create welcome.sh. It must prompt the user for their "Full Name" and "Department".
-  Print: Welcome [Full Name] to the [Department] team.
  
<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  #Prompting for user information
  read -p "Please enter your Full Name: " FULL_NAME
  read -p "Please enter your Department: " DEPARTMENT
  
  # Displaying the welcome message
  echo "Welcome $FULL_NAME to the $DEPARTMENT team." 
  ```
</details>

---

## Task 2: Parameter Validation (Security)

A senior admin needs a script that only runs if exactly 3 arguments are provided (ServerName, Port, Protocol).

### Requirement: 

- Create validate_args.sh.
- If the number of arguments is not 3, print an error message and exit with code 1. If correct, print "Configuration for $1 started."
  
<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  # Check if the number of arguments is NOT 3
  if [ $# -ne 3 ]; then
    echo "Error: Invalid number of arguments."
    echo "Usage: $0 <ServerName> <Port> <Protocol>"
    exit 1
  fi

  # If we reached here, it means we have exactly 3 arguments
  echo "Configuration for $1 started."
  ```
</details>

---

## Task 3: Automatic Directory Provisioning

You need to create several project folders for a new sprint.

### Requirement: 

- Create mksprint.sh. It should take an undefined number of arguments (folder names).
- Use a for loop to create each directory. Use logical operators (&&) to print "Created [name]" only if the mkdir command was successful.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  for folder in "$@" ; do
    mkdir "$folder" && echo "Created $folder"
  done
  ```
</details>

---

## Task 4: Service Configuration Auditor

Before a security audit, you need to check the status of certain config files in /etc.

### Requirement: 

- Create audit_files.sh that checks a given file path (provided as $1).
- Check if it is a regular file.
- Check if it is writable by your user.
- If it is writable, print a warning: "SECURITY ALERT: $1 is writable!".

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  FILE=$1

  # 1. Check if the argument was provided
  if [ -z "$FILE" ]; then
    echo "Usage: $0 <file_path>"
    exit 1
  fi

  # 2. Check if the file exists and is a regular file
  if [ -f "$FILE" ]; then
    echo "Checking file: $FILE"
    
    # 3. Check for write permissions
    if [ -w "$FILE" ]; then
        echo "SECURITY ALERT: $FILE is writable!"
    else
        echo "Success: $FILE is not writable (secure)."
    fi
  else
    echo "Error: $FILE does not exist or is not a regular file."
    exit 2
  fi
  ```
</details>

---

## Task 5: Maintenance Countdown

You are about to reboot a server and want to warn logged-in users.

### Requirement: 

- Create countdown.sh.
- Use a while loop to display a message: "Server rebooting in X seconds..." starting from 10 down to 1.



<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  COUNT=10

  while [ $COUNT -gt 0 ] ; do
    echo "Server rebooting $COUNT seconds..."
    ((COUNT--))
  done 
  ```
</details>

---

## Task 6: Privileged Execution Guard

Some scripts can crash the system if not run as root.

### Requirement:

- Create check_root.sh.
- Compare the $USER variable (or use id -u). If the user is not root, print "Error: Administrative privileges required" and exit.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  if [[ "$EUID" -ne 0 ]]; then
    echo "--------------------------------------------------------"
    echo "ERROR: This script requires administrative privileges."
    echo "Please run it using: sudo $0"
    echo "--------------------------------------------------------"
    exit 1
  fi
  ```
</details>

---

## Task 7: Log File Cleanup Simulator

The /var/log partition is filling up. You need to identify files that are actually taking up space.

### Requirement:

- Create check_logs.sh.
- Loop through all files in a directory provided as $1. For each file, check if its size is greater than 0 (-s). Only print the names of files that are NOT empty.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  LOG_DIR=$1

  # Check if a directory was provided and if it exists
  if [ -z "$LOG_DIR" ] || [ ! -d "$LOG_DIR" ]; then
    echo "Error: Please provide a valid directory."
    exit 1
  fi

  echo "Non-empty log files in $LOG_DIR:"

  # Loop through files in the directory
  for file in "$LOG_DIR"/*; do
    # -s checks if the file exists and has a size greater than zero
    if [[ -s "$file" ]]; then
        echo "Found data in: $(basename "$file")"
    fi
  done
  ```
</details>

---

## Task 8: Bulk File Rename (Migration)

You migrated files from an old server and they all have the .old extension.

### Requirement: 

- Create rename_files.sh.
- For every file in the current directory ending in .old, print "Renaming $file to ${file%.old}.txt" (You don't need to actually rename them, just simulate the output using a loop).

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  # 1. Iterate over all files in the current directory
  for file in *; do
    
    # 2. Use [[ ]] with a wildcard to filter only .old files
    if [[ $file == *.old ]]; then
        
        # 3. Simulate renaming using Shell Parameter Expansion
        # ${file%.old} removes the suffix ".old" from the variable
        echo "Migration: Renaming $file to ${file%.old}.txt"
        
    fi
  done
  ```
</details>

---

## Task 9: Connectivity Check Utility

You need to check if a list of IP addresses is responding.

### Requirement: 

- Create ping_test.sh.
- Create a script that takes one IP as an argument. Use the exit code ($?) of the ping -c 3 command to print "Server Up" or "Server Down".

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  # Check if argument exists
  if [[ -z $1 ]]; then
    echo "Error: Missing IP address."
    exit 1
  fi

  # Execute ping and check status directly in the if
  if ping -c 3 -W 5 "$1" &> /dev/null; then
    echo "Server $1 is Up"
  else
    echo "Server $1 is Down"
    exit 2
  fi

  ```
</details>

---

## Task 10: Simple System Health Report

Every morning, you need a quick summary of the system.

### Requirement:

- Create report.sh.
- Capture the output of uptime into a variable.
- Capture the number of active processes (ps aux | wc -l).
- Print a report: --- System Report [Date] ---, followed by the captured data.
- If the number of processes is greater than 500, include an "ALERT: High process count detected" message in the report.

<details>
  <summary><b> Show Solution </b></summary>

  **Command**

  ```bash
  #!/bin/bash

  UPTIME=$(uptime)
  PROCESSES=$(ps aux | wc -l)

  { 
   echo "------------------------------------------"
   echo "--- System Report $(date +%F) ---"
   echo "------------------------------------------"

   echo "UPTIME:    $UPTIME"
   echo "PROCESSES: $PROCESSES"

   if [[ $PROCESSES -gt 500 ]]; then
      echo "ALERT: High process count detected!"
   fi  
   echo -e "----------------------------------\n"
  } >> report.txt
  ```
</details>