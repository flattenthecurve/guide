#!/bin/sh
#
# Issue warning if modifications to _resource md files are present.

# Redirect output to stderr
exec 1>&2

if test $(git diff --cached --name-only | grep _resources/ | wc -l) != 0
then
    echo "!!! DO NOT MODIFY RESOURCES BY HAND !!!"
    echo "Use https://forms.gle/2zi67brmMZ7byCvb8 instead."
    exit 1
fi
