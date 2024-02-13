#!/bin/bash

source ./config.ini 

username=$usernameProduction
password=$apikeyProduction
api_url="https://api.hackerone.com/v1/hackers/programs"
page_size=100
page_number=1
total_sum=0

# Print the header
echo "Handle, Name,Submission State, URL"
url="https://hackerone.com"

while true; do
    response=$(curl -s -u "$username:$password" -H 'Accept: application/json' "$api_url?page\[size\]=$page_size&page\[number\]=$page_number" )
    count=$(echo "$response"|jq '.data | length')
    #echo "$response"|jq
    # Use jq to extract the desired values
    IFS=$'\n'
    handles=($(echo "$response" | jq -r '.data[].attributes.handle'))
    names=($(echo "$response" | jq -r '.data[].attributes.name'))
    submission_states=($(echo "$response" | jq -r '.data[].attributes.submission_state'))

    # Print the extracted values in CSV format
    for i in $(seq 0 $((${#handles[@]} - 1))); do
        echo "${handles[$i]}, ${names[$i]}, ${submission_states[$i]}, $url/${handles[$i]}"
    done
    #echo "Page: $page_number, Total objects: $count"

    # Add the count to the total sum
    ((total_sum += count))
    # Check if the count is less than the page size
    if [[ "$count" -lt "$page_size" ]]; then
        break
        #echo "next"
    else
    # Increment the page number for the next request
    ((page_number++))
    fi
done

echo "Total Sum: $total_sum"
