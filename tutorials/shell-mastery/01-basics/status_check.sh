#!/bin/bash

# --- 1. SUCCESS CASE ---
ls /etc/passwd > /dev/null 2>&1
# $? captures the exit status of the LAST command
# $? 获取上一个命令的退出状态码
echo "Last command status (Success): $?"

# --- 2. FAILURE CASE ---
ls /non_existent_file > /dev/null 2>&1
echo "Last command status (Failure): $?"

# --- 3. LOGIC CHAIN (&& and ||) ---
# && (AND): Run the next command ONLY IF the first one SUCCEEDED (0)
# || (OR):  Run the next command ONLY IF the first one FAILED (non-zero)
[[ -f "/etc/hosts" ]] && echo "Hosts file found!"
[[ -d "/tmp/missing_dir" ]] || echo "Directory missing, but I caught it."
