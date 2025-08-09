#!/bin/bash

# This script performs a two-way synchronization between the local directory
# and the remote Git repository. It commits local changes, pulls remote changes,
# and pushes the combined result.

set -e # Exit immediately if a command exits with a non-zero status.

REMOTE_REPO="git@github.com:kesaruhasun/chronicles-content.git"
BRANCH="main" # Change this to "master" if your default branch is different.

# Check if this is a git repository
if [ ! -d ".git" ]; then
  echo "This is not a git repository. Cloning from remote..."
  git clone "$REMOTE_REPO" .
else
  echo "Repository exists. Proceeding with sync..."
  # Ensure the remote URL is correct
  git remote set-url origin "$REMOTE_REPO"
fi

# Check for local changes
if [ -n "$(git status --porcelain)" ]; then
  echo "Local changes detected. Staging and committing..."
  git add .
  git commit -m "Automated sync: $(date)"
else
  echo "No local changes to commit."
fi

# Pull remote changes, rebase local commits on top
echo "Pulling remote changes..."
if ! git pull --rebase origin "$BRANCH"; then
    echo "Error: Merge conflict detected during 'git pull --rebase'."
    echo "Please resolve the conflicts manually and then run 'git rebase --continue'."
    echo "Aborting sync."
    exit 1
fi

# Push local changes to the remote
echo "Pushing changes to remote..."
git push origin "$BRANCH"

echo "Two-way synchronization complete."