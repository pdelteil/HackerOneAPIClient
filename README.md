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

Create a dummy project [here](https://hackerone.com/teams/new) (I recommend you to also create another h1 account) 

## How to use 

### createReport 

The basic use is as follows 

`./createReports.sh -mode programName domain bug`

Mode as 3 possible values
flag| Meaning  | Explanation |
|---|---|---|
-d | Dry-run mode| Won't make the API call at the end. Just to check parameters and request formation. 
-t | Testing mode| Send reports to a dummy project (usernameTesting and apikeyTesting values are going to be used from the config file) 
-p | Production mode| after you tested your reports agains a dummy project, you are ready to finally report them! 

Some reports have extra parameters, like 'open redirect' that needs the full vulnerable URL to be added as last parameter. 


#### Examples

- Creating an **open redirect** report to program prueba_h1b (dry run mode)

`./createReports.sh -d prueba_h1b vulnerable.com open-redirect https://vulnerable.com/1/_evil.com`

- Creating a report of **CVE-2019-12616** to program prueba_h1b (dry run mode). The latest parameter is the version of the PhpMyAdmin instance. 

`./createReports.sh -d prueba_h1b vulnerable.com CVE-2019-12616 4.7.7` 

- Creating a report of **CVE-2020-3580** to program prueba_h1b (dry run mode).

 `./createReports.sh -d prueba_h1b -t vulnerable.com CVE-2020-3580`

## More templates? 
I created [this](https://github.com/pdelteil/bugBountyTemplates) project with all the templates I've used. The templates were filled manually but I will migrate them to this project. (eventually) 


## Supported bugs  

- Generic Open Redirect 
- PhpMyAdmin CVE-2019-12616
- CVE-2020-3580

## Problems 

- HackerOne's API documentation is awful. There are not many examples. I hate that. 
- I still don't know how to inject markdown code into the template. 
- I was using a dummy program in my primary account but then I couldn't remove the reports sent. I recommend you to create a dummy program in a secondary account. 
- I couldn't find a way to obtain the ids of weaknesses using the API. Withouth the ID you won't be able to submit the report. 
A way to get the ID is to use the filtering function on the HackerOne web site in your Inbox seccion. If you filter by weakness you will see the ID in the resulting the URL of the filter.  

## TODO
- Define in a template file every bug definition. 
- Take screenshots of vulnerable URLS to be inclued in the reports. This could be solved using Google Photos API and then include the URL in the report.
