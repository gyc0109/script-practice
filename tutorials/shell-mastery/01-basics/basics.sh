#!/bin/bash

# --- GLOBAL VARIABLES ---
# Define variables without spaces around '='
# 定义变量时，等号两边严禁空格
GREETING="Hello, Shell World"
CURRENT_USER="${USER}"
FILE_PATH="/tmp/my test file.txt"

# --- EXECUTION ---
# Use "${var}" to prevent word splitting
# 使用双引号和花括号防止单词拆分（尤其处理带空格的文件名时）
echo "Message: ${GREETING}"
echo "Current user is: ${CURRENT_USER}"

# Correct way to handle paths with spaces
# 处理带空格路径的正确方式
printf "Target file: %s\n" "${FILE_PATH}"

# Experimenting with command substitution $(...)
# 使用 $(...) 进行命令替换
CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")
echo "System time: ${CURRENT_TIME}"
