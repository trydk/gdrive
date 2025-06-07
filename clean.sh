#!/bin/bash

# Load configuration from .env
if [ ! -f ".env" ]; then
    echo "Error: .env file not found."
    exit 1
fi
GDRIVE_FOLDER_ID=$(grep '^GDRIVE_FOLDER_ID=' ".env" | cut -d '=' -f2-)
AUTOCLEAN_OLDFILES=$(grep '^AUTOCLEAN_OLDFILES=' ".env" | cut -d '=' -f2-)
AUTOCLEAN_DAY=$(grep '^AUTOCLEAN_DAY=' ".env" | cut -d '=' -f2-)

# Check if required variables are set
if [[ -z "$GDRIVE_FOLDER_ID" || -z "$AUTOCLEAN_OLDFILES" || -z "$AUTOCLEAN_DAY" ]]; then
    echo "Error: One or more required variables (GDRIVE_FOLDER_ID, AUTOCLEAN_OLDFILES, AUTOCLEAN_DAY) are not set in .env."
    exit 1
fi

if [[ "$AUTOCLEAN_OLDFILES" == "false" ]]; then
    echo "AUTOCLEAN_OLDFILES is set to false. No files will be deleted."
    exit 0
fi

# Get access token
if [ ! -f ".access_token" ]; then
    echo "Error: .access_token file not found."
    exit 1
fi
ACCESS_TOKEN=$(cat ".access_token")

# Read Google Drive Folder
LIMIT=$(date -d "$AUTOCLEAN_DAY days ago" +%Y-%m-%dT%H:%M:%S)
QUERY="modifiedTime < '${LIMIT}' and '${GDRIVE_FOLDER_ID}' in parents"
ENCODED_QUERY=$(echo "$QUERY" | jq -sRr @uri)
FILES=$(curl -s -X GET \
    "https://www.googleapis.com/drive/v3/files?q=${ENCODED_QUERY}&fields=files(id,name)" \
    -H "Authorization: Bearer ${ACCESS_TOKEN}")

if [[ $(echo "$FILES" | jq '.files | length') -eq 0 ]]; then
    echo "No files found that were modified more than $AUTOCLEAN_DAY days ago in the folder."
    exit 0
else
    COUNT=$(echo "$FILES" | jq '.files | length')
    echo "$COUNT file(s) found that will be deleted."
fi

# Delete Files
echo "$FILES" | jq -r '.files[] | .id' | while read FILE_ID; do
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
        "https://www.googleapis.com/drive/v3/files/$FILE_ID" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}")

    if [[ "$RESPONSE" == "204" ]]; then
        echo "File with ID $FILE_ID was successfully deleted."
    else
        echo "Failed to delete file with ID $FILE_ID. Status Code: $RESPONSE"
    fi
done
