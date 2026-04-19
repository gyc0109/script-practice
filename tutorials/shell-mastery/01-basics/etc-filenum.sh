#! /bin/bash

TARGET_DIR="/etc"
FILE_COUNT=$(ls $TARGET_DIR | wc -l)

echo "$TARGET_DIR dir is $FILE_COUNT file"
