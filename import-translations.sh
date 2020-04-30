#!/usr/bin/env bash

# To import all the translations from lokalise, run the following command
#
# $ ./import-translations.sh <LOKALISE_TOKEN> [<LANG>]
#
# you can get the LOKALISE_TOKEN from https://app.lokalise.com/profile, API tokens
#
# This command will generate the _translations/<LANG>.json files and the _content/<LANG>

docker-compose run \
    --user $(id -u):$(id -g) \
    --rm web \
    /bin/bash -c "(bundle check || bundle install --jobs=3) && ruby import_language.rb $1 $2"
