# HackerOneAPIClient

<p align="left">
<a href=""> <img src="https://img.shields.io/static/v1?label=PR&message=Friendly&color=blue"></a>
<a href=""> <img src="https://img.shields.io/static/v1?label=No%20IKEA%20effect&message=in%20Here&color=red"></a>
<a href="https://twitter.com/philippedelteil"> <img src="https://img.shields.io/badge/Ask%20me-anything-1abc9c.svg"></a>
</p>


The main idea of this project is to send reports automatically (or programmatically, some day automagically) to HackerOne programs.  

## Configuration 

Setup your HackerOne username and APIkey into the config.txt file. 

Get your API Key [here](https://docs.hackerone.com/hackers/api-token.html)

Create a dummy project [here](https://hackerone.com/teams/new) (I recommend you to also create another h1 account, otherwise you might have too many reports and reports sent to your dummy program cannot be deleted) 

## How to use 

### createReport 

The basic use is as follows:

`./createReports.sh -mode programName domain bug`

Mode as 3 possible values
flag| Meaning  | Explanation |
|---|---|---|
-d | Dry-run mode| Won't make the API call at the end. Just to check parameters and request formation. 
-t | Testing mode| Send reports to a dummy project (*usernameTesting* and *apikeyTesting* values are going to be used from the config file) 
-p | Production mode| Use production mode after you tested your reports against a dummy project, then you are ready to finally report them! 

Some reports have extra parameters, like *open redirect* that needs the full vulnerable URL to be added as last parameter. 


#### Examples

- Creating an **open redirect** report to program prueba_h1b (dry run mode)

`./createReports.sh -d prueba_h1b vulnerable.com open-redirect https://vulnerable.com/1/_evil.com`

- Creating a report of **CVE-2019-12616** to program prueba_h1b (dry run mode). The latest parameter is the version of the PhpMyAdmin instance. 

`./createReports.sh -d prueba_h1b vulnerable.com CVE-2019-12616 4.7.7` 

- Creating a report of **CVE-2020-3580** to program prueba_h1b (dry run mode).

`./createReports.sh -d prueba_h1b vulnerable.com CVE-2020-3580`
 
- Creating a report of **Generic Reflected XSS** to program prueba_h1b (dry run mode). 

`./createReports.sh -d prueba_h1b target.domain.com xss "https://target.domain/XXS_payload"`
  
- Creating a report of **S3 bucket takeover** to program prueba_h1b (dry run mode)
 
`./createReports.sh -d prueba_h1b target.domain.com s3takeover`

- Creating a report of **Azure Cloud App subdomain takeover** to program prueba_h1b (dry run mode)

`./createReports.sh -d prueba_h1b target.domain.com azureCloudAppSto https://web.archive.org/web/20240506140901/https://target.domain.com/ cname.target.domain.com`

## More templates? 
I created [this](https://github.com/pdelteil/bugBountyTemplates) project with all the templates I've used. The templates were filled manually but I will migrate them to this project. (eventually) 


## Supported bugs  

- Generic Open Redirect 
- Generic Reflected XSS
- PhpMyAdmin CVE-2019-12616
- CVE-2020-3580
- S3 takeover
- XSS in Swagger UI
- Azure Cloud App subdomain takeover

## Problems 

- HackerOne's API documentation is awful. There are not many examples. I hate that. 
- ~~I still don't know how to inject markdown code into the template.~~
- ~~I couldn't find a way to obtain the ids of weaknesses using the API. Withouth the ID you won't be able to submit the report. A way to get the ID is to use the filtering function on the HackerOne web site in your Inbox section. If you filter by weakness you will see the ID in the resulting the URL of the filter.~~
- Not all programs have the same weaknesses, you may encounter a 500 error if you send a weakness id that the program doesn't have (this is really silly).

## TODO
- Use yaml to define every type of bug. (Just like nuclei templates) 
- Take screenshots of vulnerable URLS to be inclued in the reports. This could be solved using Google Photos API and then include the URL in the report.
- Save an url using a web archive service and get the link to be added in the report. 
