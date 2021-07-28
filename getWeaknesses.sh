#This call will retrieve the weaknesses related to a program

program=$1
#load credentials
. ./config.txt

curl "https://api.hackerone.com/v1/hackers/programs/$program/weaknesses" \
  -X GET \
  -u "$usernameProduction:$apikeyProduction" \
  -H 'Accept: application/json'

