#!/bin/bash

# Check if program handle is provided as input parameter
if [ -z "$1" ]; then
    echo "Usage: $0 <program_handle>"
    exit 1
fi

program=$1
#load credentials
source ./config.ini

# Set the initial page number and page size
PAGE_NUMBER=1
PAGE_SIZE=100

# Loop until there are no more pages left
while true; do
    # Make a request to retrieve data for the current page
    RESPONSE=$(curl -s "https://api.hackerone.com/v1/hackers/programs/$program/weaknesses" \
  --data-urlencode "page[size]=$PAGE_SIZE" \
  --data-urlencode "page[number]=$PAGE_NUMBER" \
  -X GET \
  -u "$usernameProduction:$apikeyProduction" \
  -H 'Accept: application/json')
    # Check if the response is empty
    if [ "$(echo "$RESPONSE" | jq '.data | length')" -eq 0 ]; then
        break
    fi

    # Save the response of each page to a separate JSON file
    echo "$RESPONSE" 

    # Increment the page number for the next iteration
    ((PAGE_NUMBER++))
done

