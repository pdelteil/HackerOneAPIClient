#!/bin/bash
source ./config.ini

username=$usernameProduction
password=$apikeyProduction

input=$1

api_url="https://api.hackerone.com/v1/hackers/programs/$input/structured_scopes"

response=$(curl -s -u "$username:$password" -H 'Accept: application/json' "$api_url")
echo $response|jq -r '.data | map(select(.attributes.eligible_for_submission and (.attributes.asset_type == "WILDCARD" or .attributes.asset_type == "URL")) | .attributes.asset_identifier) | .[]'
