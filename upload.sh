#!/bin/bash

# Load configuration from .env
if [ ! -f ".env" ]; then
  echo "Error: .env file not found."
  exit 1
fi
GDRIVE_FOLDER_ID=$(grep '^GDRIVE_FOLDER_ID=' ".env" | cut -d '=' -f2-)
DELETE_AFTER_UPLOAD=$(grep '^DELETE_AFTER_UPLOAD=' ".env" | cut -d '=' -f2-)
LOCAL_FOLDER_PATH=$(grep '^LOCAL_FOLDER_PATH=' ".env" | cut -d '=' -f2-)

# Get access token
if [ ! -f ".access_token" ]; then
  echo "Error: .access_token file not found."
  exit 1
fi
ACCESS_TOKEN=$(cat ".access_token")

RESULT=""
# Loop through all files in the local folder
for FILE in "$LOCAL_FOLDER_PATH"/*; do
  # Only upload files, not directories
  if [[ -f "$FILE" ]]; then
    FILENAME=$(basename "$FILE")

    # Upload file to Google Drive
    UPLOAD=$(curl -v -X POST \
      -L \
      -H "Authorization: Bearer $ACCESS_TOKEN" \
      -F "metadata={name :'$FILENAME', parents:['$GDRIVE_FOLDER_ID']};type=application/json" \
      -F "file=@$FILE" \
      "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")
    FILE_ID=$(echo "$UPLOAD" | jq -r .id)
    
    # Result per file
    if [[ -n "$FILE_ID" && "$FILE_ID" != "null" ]]; then
      RESULT+="Successfully uploaded $FILENAME (File ID: $FILE_ID)."
    else
      RESULT+="Failed to upload $FILENAME."
    fi
    RESULT+="\n"

    # Delete the file after upload
    if [[ "$DELETE_ORIGIN_AFTER_UPLOAD" == "true" ]]; then
      rm "$FILE"
    fi
  fi
done

echo "============="
echo "Upload Result"
echo "============="
echo -e "$RESULT"
