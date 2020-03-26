#!/usr/bin/env python3
import datetime
import os
import pickle
import re

from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request

TOKEN_FILE = '.google_oauth_token'
SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']
RESOURCES_SHEET_ID = '1QSQgxceR8BL03qsR-GY8bw4tsdsx30kovU7wVXPUcxo'
RANGE = 'Form Responses 1!A2:J'

COL_TIMESTAMP = 0
COL_SUBMITTER = 1
COL_MEETS_STANDARDS = 2
COL_CATEGORY = 3
COL_COUNTRY = 4
COL_URL = 5
COL_NAME = 6
COL_DESCRIPTION = 7
COL_STATE = 8
COL_VERIFIED_BY = 9
# TODO: we could write integrated_timestamp into the spreadsheet if
# we want to have a record of this action.
ENABLE_VERIFICATION = True
"""If enabled, only import resources if they have ApprovedBy column set."""


def is_approved(row):
    if not ENABLE_VERIFICATION:
        return True
    if COL_VERIFIED_BY >= len(row) or not row[COL_VERIFIED_BY]:
        return False
    return True


def make_row_filename(row):
    """Constructs standardized base filename for this resource.
    
    We will use YYYY-MM-DD of the submission timestamp followed by first 25
    characters of the resource title with spaces replaced with dashes.
    """
    sanitized_name = row[COL_NAME].lower().replace(" ", "-")[:35].strip("-")
    sanitized_name = re.sub(r'--*', '-', sanitized_name)
    dt = datetime.datetime.strptime(
        row[COL_TIMESTAMP].split()[0],
        '%m/%d/%Y').date()
    return f'{dt.isoformat()}-{sanitized_name}.md'


def sanitize_country(country):
    """Ensure consistent country naming schemes."""
    return {
        "United States": "USA",
    }.get(country, country)


# List of dictionaries describing columns. Possible dictionary keys are:
# - required (bool): if True, column has to be non-empty
# - name (str): name of the column to use when emitting md files
# - index (int): which column contains the data
# - transform_fn (func): function that takes one argument and returns
#     sanitized form.
ATTRIBUTES_TO_EXTRACT = [
    {'required': True,
     'name': 'name',
     'index': COL_NAME},
    {'required': True,
     'name': 'category',
     'index': COL_CATEGORY},
    {'name': 'country',
     'index': COL_COUNTRY,
     'transform_fn': sanitize_country},
    {'name': 'state', 'index': COL_STATE}]


def check_required_columns(row):
    """Checks that all required columns are present."""
    for attr in ATTRIBUTES_TO_EXTRACT:
        if not attr.get('required', False):
            continue
        if not row[attr['index']]:
            return False
    return True

    
def format_row_contents(row):
    """Generate MD output for each row."""
    attribute_rows =[]
    for attr in ATTRIBUTES_TO_EXTRACT:
        col = attr['index']
        if col >= len(row) or not row[col]:
            continue
        value = attr.get('transform_fn', lambda x: x)(row[col]).strip()
        attribute_rows.append(f"{attr['name']}: {value}")
    all_attributes = "\n".join(attribute_rows)
    return (
        f"---\n"
        f"{all_attributes}\n"
        f"\nURL: {row[COL_URL].strip()}\n"
        f"---\n"
        f"\n"
        f"{row[COL_DESCRIPTION]}")


def setup_service():
    creds = None
    # Store auth tokens for googleapi access in TOKEN_FILE, after 
    # the auth flow runs for the first time.
    if os.path.exists(TOKEN_FILE):
        with open(TOKEN_FILE, 'rb') as token:
            creds = pickle.load(token)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open(TOKEN_FILE, 'wb') as token:
            pickle.dump(creds, token)

    return build('sheets', 'v4', credentials=creds)
    

def get_resource_dir():
    """Finds _resources/ directory or terminates this script."""
    for res in ['_resources/', '../_resources']:
        if os.path.isdir(res):
            return res
    sys.exit("Can't find _resources/ directory.")
    return None


def main():
    # Find either _resources or ../_resources directory
    resource_dir = get_resource_dir()
    service = setup_service()
    sheet = service.spreadsheets()
    result = sheet.values().get(spreadsheetId=RESOURCES_SHEET_ID,
                                range=RANGE).execute()
    values = result.get('values', [])
    rows_accepted = 0
    for row_num, row in enumerate(values, start=2):
        if not row[COL_MEETS_STANDARDS].lower() == 'yes':
            print(f'Skipping row {row_num} because it doesn\'t meet FTC criteria.')
            continue
        if not is_approved(row):
            print(f'Skipping row {row_num} because it is not marked as approved.')
            continue
        if not check_required_columns(row):
            continue
        filename = f'{resource_dir}/{make_row_filename(row)}'
        with open(filename, 'w+') as out_file:
            rows_accepted += 1
            out_file.write(format_row_contents(row))
            out_file.close()

    print(f'Imported {rows_accepted} resources.')
            
        

if __name__ == '__main__':
    main()
