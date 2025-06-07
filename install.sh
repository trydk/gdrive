#!/bin/bash

# Load configuration from .env
if [ ! -f ".env" ]; then
  echo "Error: .env file not found."
  exit 1
fi
EMAIL=$(grep '^EMAIL=' .env | cut -d '=' -f2-)
CLIENT_ID=$(grep '^CLIENT_ID=' .env | cut -d '=' -f2-)
CLIENT_SECRET=$(grep '^CLIENT_SECRET=' .env | cut -d '=' -f2-)
AUTHORIZATION_CODE=$(grep '^AUTHORIZATION_CODE=' .env | cut -d '=' -f2-)

# Request access and refresh tokens
TOKEN_RESPONSE=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d "code=$AUTHORIZATION_CODE" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "redirect_uri=http://localhost" \
  -d "grant_type=authorization_code")
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r .access_token)
REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r .refresh_token)

if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
  echo "========================================================================================================="
  echo "Failed to get ACCESS_TOKEN."
  echo "Open this URL in your browser, copy the code from the redirect URL, and update AUTHORIZATION_CODE in .env"
  echo "========================================================================================================="
  echo "https://accounts.google.com/o/oauth2/v2/auth?response_type=code&client_id=$CLIENT_ID&redirect_uri=http://localhost&scope=https://www.googleapis.com/auth/drive&access_type=offline&login_hint=$EMAIL"
  exit 1
fi

echo "$ACCESS_TOKEN" > .access_token
echo "$REFRESH_TOKEN" > .refresh_token

echo "================================================="
echo "The installation has been completed successfully."
echo "================================================="
echo "Access Token: $ACCESS_TOKEN"
echo "Refresh Token: $REFRESH_TOKEN"
