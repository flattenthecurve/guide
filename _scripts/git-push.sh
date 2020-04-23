#!/usr/bin/env bash

# Usage: git-push.sh ${branch_name} ${commit_message}
# 
# This script will add local changes, commit with given message
# and then pushes given ${branch_name} to remote repo.

set -e
branch="$1"
commit_message="$2"

if [ -z "$branch" -o -z "$commit_message" ]; then
    echo "Usage: git-push.sh branch_name commit_message"
    exit 1
fi

remote_repo="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git remote add github $remote_repo
git config user.name "${GITHUB_ACTOR}"
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
git checkout -B $branch
git add .
git commit -m "$commit_message" >/dev/null 2>&1
git push --force $remote_repo $branch:$branch >/dev/null 2>&1
