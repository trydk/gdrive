#!/bin/bash

# Load configuration from .env
if [ ! -f ".env" ]; then
  echo "Error: .env file not found."
  exit 1
fi
CLIENT_ID=$(grep '^CLIENT_ID=' .env | cut -d '=' -f2-)
CLIENT_SECRET=$(grep '^CLIENT_SECRET=' .env | cut -d '=' -f2-)

# Get refresh token
if [ ! -f ".refresh_token" ]; then
  echo "Error: .refresh_token file not found."
  exit 1
fi
REFRESH_TOKEN=$(cat ".refresh_token")

# Request new access token
RESPONSE=$(curl -sS -X POST https://oauth2.googleapis.com/token \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  -d "refresh_token=$REFRESH_TOKEN" \
  -d "grant_type=refresh_token")
ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r .access_token)

# Save access token and print result
if [[ -n "$ACCESS_TOKEN" && "$ACCESS_TOKEN" != "null" ]]; then
  echo "$ACCESS_TOKEN" > ".access_token"
  echo "==============================================="
  echo "The refresh process was completed successfully."
  echo "==============================================="
  echo "Access Token: $ACCESS_TOKEN"
else
  echo "Failed to refresh access token."
  exit 1
fi