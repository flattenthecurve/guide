#!/usr/bin/env bash

set -e

remote_repo="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git" && \
remote_branch="preview/translation-$IMPORT_LANG" && \
git remote add github $remote_repo && \
git config user.name "${GITHUB_ACTOR}" && \
git config user.email "${GITHUB_ACTOR}@users.noreply.github.com" && \
git checkout -b $remote_branch && \
git add . && \
echo -n 'Files to Commit:' && ls -l | wc -l && \
git commit -m"Update _content/$IMPORT_LANG from Lokalise" > /dev/null 2>&1 && \
git push --force $remote_repo $remote_branch:$remote_branch > /dev/null 2>&1
