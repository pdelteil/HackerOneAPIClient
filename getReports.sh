#load credentials
. ./config.local.txt

curl  "https://api.hackerone.com/v1/hackers/me/reports" \
  -u "$usernameProduction:$apikeyProduction" \
  -H 'Accept: application/json'
