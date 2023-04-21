#!/bin/bash

CONTAINER_NAME="flask-app"
EXPECTED_PORT="8088"
API_BASE_URL="http://127.0.0.1:${EXPECTED_PORT}"
KEY="test_key"
VALUE="test_value"

# Check if the container is running
if docker ps --filter "name=${CONTAINER_NAME}" | grep -q "${CONTAINER_NAME}"; then
    echo "Container ${CONTAINER_NAME} is running."

    # Check if the expected port is accessible
    if nc -z -w5 127.0.0.1 ${EXPECTED_PORT}; then
        echo "Port ${EXPECTED_PORT} is accessible."

        # Set key-value pair using POST request
        response=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"key\": \"${KEY}\", \"value\": \"${VALUE}\"}" "${API_BASE_URL}/set")
        status=$(echo "$response" | jq -r '.status')
        message=$(echo "$response" | jq -r '.message')
        
        if [[ $status == "success" ]]; then
            echo "POST request succeeded. Key-value pair set successfully."
        else
            echo "POST request failed."
            exit 1
        fi

        # Get value by key using GET request
        response=$(curl -s "${API_BASE_URL}/get/${KEY}")

        expected_response="{\"key\":\"${KEY}\",\"value\":\"${VALUE}\"}"
        if [[ $response == $expected_response ]]; then
            echo "GET request succeeded. Value retrieved for key ${KEY}: ${VALUE}"
        else
            echo "GET request failed."
            exit 1
        fi

    else
        echo "Port ${EXPECTED_PORT} is not accessible."
        exit 1
    fi
else
    echo "Container ${CONTAINER_NAME} is not running."
    exit 1
fi
