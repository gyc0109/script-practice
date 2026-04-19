#!/bin/bash

# --- VARIABLE DEFINITION ---
SKILL="Shell Scripting"
PRICE=100

# --- SINGLE QUOTES ('') ---
# Strong quoting: Every character is literal. No expansion.
# 强引用：所有字符都被视为普通字符串，不进行变量替换。
echo 'Single Quotes: I love ${SKILL}, it costs $PRICE'

# --- DOUBLE QUOTES ("") ---
# Weak quoting: Allows Variable Expansion and Command Substitution.
# 弱引用：允许变量扩展和命令替换。
echo "Double Quotes: I love ${SKILL}, it costs \$${PRICE}"

# --- NESTING & SPACES ---
# Double quotes are essential when the variable contains spaces.
# 当变量包含空格时，双引号是保护 Token 不被再次拆分的防线。
SENTENCE="This is a   long   space"
echo "With quotes: ${SENTENCE}"
echo Without quotes: ${SENTENCE}
