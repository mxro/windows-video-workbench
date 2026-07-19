#!/bin/bash
set -euo pipefail

has_error=0

on_error() {
    has_error=1
}

trap on_error ERR

TARGET_DIR_WIN="C:\Users\mxro\Videos\windows-video-workbench"

# Convert Windows path to WSL format
TARGET_DIR=$(wslpath -u "$TARGET_DIR_WIN")

echo "Deleting target folder: $TARGET_DIR"
rm -rf "$TARGET_DIR"

echo "Creating target folder..."
mkdir -p "$TARGET_DIR"

echo "Copying scripts and executables..."
for item in *; do
    if [ "$item" != "install.sh" ] && [ "$item" != "README.md" ]; then
        cp -r "$item" "$TARGET_DIR/"
    fi
done

echo "Done!"

if [ "$has_error" -eq 1 ]; then
    echo ""
    echo "Some errors occurred. Press any key to exit..."
    read -r -p ""
fi