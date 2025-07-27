#!/bin/sh
set -e

# Clean appdata directory
rm -rf /appdata/*

# Find latest backup tar.gz file
LATEST_TAR=$(ls -1t /backup/*.tar.gz | head -n1)

# Extract backup
tar -xzvf "$LATEST_TAR" -C /appdata