#! /bin/bash

# 1. 定义一个变量 DIR_NAME，值为 My Documents（中间有空格）。
# 
# 2. 使用 mkdir 命令创建这个目录。
# 
# 3. 核心测试：尝试不加双引号执行 mkdir ${DIR_NAME}，观察发生了什么？
# 
# 4. 进阶：尝试在 echo 中输出这段话：The system path is $PATH。要求输出结果中必须显示 $PATH 这四个字符，而不是那一长串路径。

DIR_NAME="My Documents"

mkdir "${DIR_NAME}"

ls -al .

# Clean up
rmdir "${DIR_NAME}"

echo 'The system path is $PATH'
echo The system path is $PATH

