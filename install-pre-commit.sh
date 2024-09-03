#!/bin/bash

# Define the URL of the pre-commit script
PRE_COMMIT_URL="https://raw.githubusercontent.com/vvadymv/precommit-gitleaks/main/pre-commit"

# Check if the script is being run inside a Git repository
if [ ! -d ".git" ]; then
  echo "Error: This script must be run inside a Git repository."
  exit 1
fi

# Define the path for the pre-commit hook
HOOK_PATH=".git/hooks/pre-commit"
BACKUP_PATH=".git/hooks/pre-commit.orig"

# Check if the script is already in the hooks directory
if [ -f "$HOOK_PATH" ]; then
  echo "Existing pre-commit hook detected. Backing up to $BACKUP_PATH..."
  cp "$HOOK_PATH" "$BACKUP_PATH"
fi

# Download the pre-commit script from the repository
echo "Downloading pre-commit script..."
curl -sSfL "$PRE_COMMIT_URL" -o "$HOOK_PATH"

# Check if the download was successful
if [ ! -f "$HOOK_PATH" ]; then
  echo "Error: Failed to download the pre-commit script. Please check your internet connection or the URL."
  exit 1
fi

# Make the pre-commit script executable
chmod +x "$HOOK_PATH"
echo "Pre-commit hook installed successfully at $HOOK_PATH."
