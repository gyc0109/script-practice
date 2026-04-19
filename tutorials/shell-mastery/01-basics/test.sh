#!/bin/bash

MY_NAME="Genius"
echo $MY_NAME

# 为什么程序不修改会报错，因为 "MY_NAME = "Genius"" 中"="出现了空格，shell的语法是不允许这种格式的
