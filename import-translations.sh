#!/usr/bin/env bash

# To import all the translations from lokalise, run the following command
#
# $ ./import-translations.sh <LOKALISE_TOKEN>
#
# you can get the LOKALISE_TOKEN from https://app.lokalise.com/profile, API tokens
#
# This command will generate the _translations/<LANG>.json files and the _content/<LANG>

LOKALISE_TOKEN=$1

docker-compose run --rm web /bin/bash -c "(bundle check || bundle install --jobs=3) && ruby import_language.rb $LOKALISE_TOKEN"
