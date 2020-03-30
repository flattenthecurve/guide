#!/usr/bin/env python3
import argparse
import csv
import datetime
import io
import os
import re
import requests

# Resource spreadsheet contents are published at this URL in the form of CSV
RESOURCES_URL="https://docs.google.com/spreadsheets/d/e/2PACX-1vQMEdZXKgYNybkqNv4X26CVNoQZHuE0zb27wuBDgdDwtiyWCICQLhyU_LuLJVeHD5oTRnp-bEdFTuqi/pub?gid=650653420&single=true&output=csv"

parser = argparse.ArgumentParser(description='Parse arguments for this script.')
parser.add_argument('--dryrun', '-n', default=False, action="store_true")
args = parser.parse_args()
"""Commandline argument values are stored here."""

REQUIRED_COLUMNS = ['name', 'category', 'description']
"""These columns must be non-empty for the row to be accepted."""

EXTRACT_ATTRIBUTES = ['name', 'category', 'country', 'state']
"""Columns that will be added into MD file as attributes, in this order."""


def make_row_filename(row):
    """Constructs standardized base filename for this resource.

    Adds timestamp prefix, lowercased alphanumeric character from the title
    are retained, spaces replaced with dashes and total length of title
    limited at 35 characters.

    Returns the resulting base filename.
    """
    sanitized_name = row['name'].lower().replace(" ", "-")
    sanitized_name = re.sub(r'[^-a-zA-Z0-9]', '', sanitized_name)
    sanitized_name = re.sub(r'--*', '-', sanitized_name)
    sanitized_name = sanitized_name[:35].strip("-")
    dt = datetime.datetime.strptime(
        row['timestamp'].split()[0],
        '%m/%d/%Y').date()
    return f'{dt.isoformat()}-{sanitized_name}.md'

   
def format_row_contents(row):
    """Generate MD output for each row."""
    attr_rows = []
    for attr in EXTRACT_ATTRIBUTES:
        if not row.get(attr, None):
            continue
        # TODO: ensure special character escaping.
        attr_rows.append(f'{attr}: {row[attr]}')
    all_attributes = '\n'.join(attr_rows)
    return (
        f"---\n"
        f"{all_attributes}\n"
        f"\nURL: {row['url'].strip()}\n"
        f"---\n"
        f"\n"
        f"{row['description']}")


def get_resource_dir():
    """Finds _resources/ directory or terminates this script."""
    for res in ['_resources/', '../_resources']:
        if os.path.isdir(res):
            return res
    sys.exit("Can't find _resources/ directory.")
    return None


def main():
    resource_dir = get_resource_dir()
    resources = requests.get(RESOURCES_URL)
    resources.encoding = 'utf-8'
    rows = csv.DictReader(io.StringIO(resources.text))
    rows_accepted = 0
    for row_num, row in enumerate(rows, start=2):
        # Check that all required columns are present
        has_required = True
        for reqd in REQUIRED_COLUMNS:
            if not row.get(reqd, None):
                print("Row {row_num} skipped. It is missing required column '{reqd}'.")
                has_required = False
                break
        if not has_required:
            continue

        rows_accepted += 1
        filename = f'{resource_dir}{make_row_filename(row)}'
        
        if args.dryrun:
            print(f"*** Dry run *** {filename} would contain:")
            print(format_row_contents(row))
        else:
            with open(filename, encoding='utf-8', mode='w+') as out_file:
                out_file.write(format_row_contents(row))
                out_file.close()

    print(f'Imported {rows_accepted} resources.')
        

if __name__ == '__main__':
    main()
