#!/bin/bash

# Load environment variables form .env file
export $(grep -v '^#' .env | xargs)

# Debug purpose
echo "API_KEY: $API_KEY"
echo "PROJECT_NUMBER: $PROJECT_NUMBER"
echo "PROJECT_ID: $PROJECT_ID"
echo "STORAGE_BUCKET: $STORAGE_BUCKET"
echo "APP_ID: $APP_ID"
echo "PACKAGE_NAME: $PACKAGE_NAME"

# Generate google-services.json from template
sed "s/\${API_KEY}/${API_KEY}/g; s/\${PROJECT_NUMBER}/${PROJECT_NUMBER}/g; s/\${PROJECT_ID}/${PROJECT_ID}/g; s/\${STORAGE_BUCKET}/${STORAGE_BUCKET}/g; s/\${APP_ID}/${APP_ID}/g; s/\${PACKAGE_NAME}/${PACKAGE_NAME}/g;" google-services-template.json > android/app/google-services.json