# 03-Create simple shell scripts

This guide covers basic Bash scripting for RHCSA, including:

- Conditional execution
- File test operators
- Script variables
- Loops
- Comparison operators
- Logical operators (&&, ||)
- Shebang and script execution

---

## 3.1. Shebang (#!) and Script Execution

```bash
#!/bin/bash
```

Tells the OS which interpreter will run the script (Bash here).

### Execution methods:

- **Explicit Bash execution**

    ```bash
    bash script.sh
    ```
    **Works without execute permissions.**

- **Direct execution**
    
    ```bash
    ./script.sh
    ```

    ***Script must be executable:**
    ```bash
    chmod +x script.sh
    ```

---

## 3.2. File Test Operators


| **Operator** | **Meaning** | **Example** |
| :---:| :--- | :--- |
| -f | Regular file exists | [ -f file.txt ] |
| -d | Directory exists | [ -d /etc/config ] |
| -e | Exists (file, directory, symlink) | [ -e /tmp/test ] |
| -s | Size > 0 | [ -s log.txt ] |
| -L | Symbolic link | [ -L /root/link ] |
| -r | Readable | [ -r file.txt ] |
| -w | Writable | [ -w file.txt ] |
| -x | Executable |	[ -x script.sh ] |

**Example:**

```bash
#!/bin/bash

FILE=$1
[ -f "$FILE" ] && echo "$FILE is a regular file"
[ -d "$FILE" ] && echo "$FILE is a directory"
[ -r "$FILE" ] && echo "$FILE is readable"
[ -w "$FILE" ] && echo "$FILE is writable"
[ -x "$FILE" ] && echo "$FILE is executable"
```

---

## 3.3. Special Script Variables

| **Variable** | **Meaning** |
| :--- | :--- |
| $0 | Script name | 
| $1-$9 | Arguments 1-9 |
| ${10}... | Arguments 10+ (requires {}) |
| $# | Number of arguments |
| $@ | All arguments separately (safe in loops) |
| $* | All arguments as a single string |
| $? | Exit code of last command |
| $$ | PID of current script |
| $! | PID of last background command |
| ${!} | Indirect expansion |
| $USER | Current user |
| $HOME | User home directory |

**Example:**

```bash
#!/bin/bash

echo "Script name: $0"
echo "Number of arguments: $#"
echo "All arguments (\$@): $@"
echo "All arguments (\$*): $*"
```

---

## 3.4. Comparison Operators

**Numeric**

| **Operator** | **Meaning** |
| :---: | :--- |
| -eq |	equal |
| -ne |	not equal |
| -gt |	greater than |
| -ge |	greater or equal |
| -lt |	less than |
| -le |	less or equal |

```bash
#!/bin/bash

NUM1=$1
NUM2=$2

if [ $NUM1 -eq $NUM2 ]; then
    echo "$NUM1 is equal to $NUM2"
fi

if [ $NUM1 -ne $NUM2 ]; then
    echo "$NUM1 is not equal to $NUM2"
fi

if [ $NUM1 -gt $NUM2 ]; then
    echo "$NUM1 is greater than $NUM2"
fi

if [ $NUM1 -lt $NUM2 ]; then
    echo "$NUM1 is less than $NUM2"
fi

if [ $NUM1 -ge $NUM2 ]; then
    echo "$NUM1 is greater than or equal to $NUM2"
fi

if [ $NUM1 -le $NUM2 ]; then
    echo "$NUM1 is less than or equal to $NUM2"
fi
```

**String**

| **Operator** | **Meaning** |
| :---: | :--- |
| == | equal |
| != | not equal |
| -z | string is empty |
| -n | string is not empty |

**Tip:** Always use double quotes for strings to prevent errors if the variable is empty.

```bash
#!/bin/bash

[ "$STR1" == "$STR2" ]  # equal
[ "$STR1" != "$STR2" ]  # not equal
```

---

## 3.5. Logical Operators: && and ||

command1 && command2 → command2 executes only if command1 succeeds

command1 || command2 → command2 executes only if command1 fails

**Examples:**

```bash
#!/bin/bash

FILE="/etc/passwd"

[ -f "$FILE" ] && echo "$FILE exists" || echo "$FILE missing"
mkdir /tmp/demo && echo "Directory created" || echo "Failed to create"
```

---

## 3.6. Loops

- **Bash-style for loop**

```bash
#!/bin/bash

for FILE in "$@"; do
    [ -e "$FILE" ] && echo "$FILE exists" || echo "$FILE does not exist"
done
```

- **C-style for loop**

```bash
#!/bin/bash

for (( i=1; i<=$#; i++ )); do
    ARG=${!i}   # Indirect expansion
    [ -e "$ARG" ] && echo "Arg $i: $ARG exists" || echo "Arg $i: $ARG missing"
done
```

- **While loop**

```bash
#!/bin/bash

COUNT=1

while [ $COUNT -le 5 ]; do
    echo "Count is $COUNT"
    ((COUNT++))
done
```

- **Until loop**

```bash
#!/bin/bash

until [ $COUNT -gt 5 ]; do
    echo "Count is $COUNT"
    ((COUNT++))
done
```

---

## 3.7. User Input (read)

The `read` command allows you to capture user input. Use `-p` for a prompt and `-s` for sensitive data (passwords).

```bash
#!/bin/bash

read -p "Enter your name: " NAME
read -sp "Enter your password: " PASS
echo -e "\nWelcome $NAME"
```