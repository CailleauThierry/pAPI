<#
Get-DataDeletionDetail.ps1 v 0.0.0.1 on 07_17_2023
From: Thierry Cailleau requires pAPI 1.5 . Its swagger API documentation is available under:
https://Your_API_Server/monitoring/swaggerui/index > Safeset > Expand Operations > Model
On this hostname "papi16" https://10.9.168.97/monitoring/swaggerui/index
Assumes you have registered the Vault to pAPI (dunring 8.40 upgrade or after from the cmd.exe as per Carbonite Director v8.4 - Install Guide.pdf:

C:\Director\ReportingService>.\ReportingService.exe -cmdline -register -uri https://10.9.168.97:8080 -id Carbonite-Registration-Client -secret fHYQA1byZ/X9Vb0psP62TLDA1VO38I1k5BOjJSbDkcNb
Registered vault)
#>
#Requires -Version 5
$token = (C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Token.ps1)
$url = 'https://10.9.168.97/monitoring/datadeletiondetails?$count=true'
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json;api-version=1"}
$reply = Invoke-RestMethod -Uri $url -Method GET -Headers $headers

$count = $reply.'@odata.count'
$collection = $reply.value

Write-Output "We found $count datadeletiondetails"
$collection | Format-List *
$collection | Format-Table -AutoSize

<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> . 'C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-DataDeletionDetail.ps1'
We found 2 datadeletiondetails


id                              : 1
deletionType                    : Safeset
jobId                           : e483d224-5697-44f9-a4b1-86104fbd65dc
jobName                         : ERRORLOG
agentId                         : 61f791c9-ea4b-41e4-9806-1dd8f4f284fb
agentName                       : TCSQL2019
companyId                       : 1858f50a-4a7e-4a7a-b1be-d9e0d3e4ef26
companyName                     : Thierry
vaultId                         : 24d02310-ba6f-41f0-ad69-75f9dd9acae2
vaultName                       : TCD1
safesetIds                      : 213:63237122
vaultComputerId                 : 883543c7-8b12-4d99-a88b-ef6473584146
deletionRequestedByUserId       : 6b93f1d3-1858-4e3b-ac79-d1043d232f29
deletionRequestDateUtc          : 2023-07-19T15:53:18.6425659Z
scheduledDeletionTimeUtc        : 2023-07-19T15:53:18.6425659Z
timeDeletionRequestCancelledUtc :
cancelledByUserId               :
timeJobDeletedFromPortalUtc     :
timeJobDeletedFromAgentUtc      :
timeAgentDeletedFromPortalUtc   :
vaultDeletionRequestId          : fe8c0ac9-dfc8-4959-ad8b-95a1b5b90bf7
timeVaultDeletionRequestSentUtc : 2023-07-19T16:00:00.3283905Z
deletedFromVault                : True
parentScheduledDeletionId       :
failureEvents                   : {}

id                              : 2
deletionType                    : Job
jobId                           : d306910c-252b-4ed7-8575-f98778d99d0e
jobName                         : AJ_Test_Delete_from_Portal
agentId                         : 61f791c9-ea4b-41e4-9806-1dd8f4f284fb
agentName                       : TCSQL2019
companyId                       : 1858f50a-4a7e-4a7a-b1be-d9e0d3e4ef26
companyName                     : Thierry
vaultId                         : 24d02310-ba6f-41f0-ad69-75f9dd9acae2
vaultName                       : TCSat8-1
safesetIds                      :
vaultComputerId                 : 883543c7-8b12-4d99-a88b-ef6473584146
deletionRequestedByUserId       : fc331dbb-c1be-4303-8f2e-a0f9ddebff7f
deletionRequestDateUtc          : 2023-08-15T14:31:10.0161578Z
scheduledDeletionTimeUtc        : 2023-08-18T14:31:10.0161578Z
timeDeletionRequestCancelledUtc :
cancelledByUserId               :
timeJobDeletedFromPortalUtc     :
timeJobDeletedFromAgentUtc      :
timeAgentDeletedFromPortalUtc   :
vaultDeletionRequestId          :
timeVaultDeletionRequestSentUtc :
deletedFromVault                : False
parentScheduledDeletionId       :
failureEvents                   : {}




id deletionType jobId                                jobName                    agentId                              agentName companyId                            companyName vaultId
-- ------------ -----                                -------                    -------                              --------- ---------                            ----------- -------
 1 Safeset      e483d224-5697-44f9-a4b1-86104fbd65dc ERRORLOG                   61f791c9-ea4b-41e4-9806-1dd8f4f284fb TCSQL2019 1858f50a-4a7e-4a7a-b1be-d9e0d3e4ef26 Thierry     24d02310-ba6f-4...
 2 Job          d306910c-252b-4ed7-8575-f98778d99d0e AJ_Test_Delete_from_Portal 61f791c9-ea4b-41e4-9806-1dd8f4f284fb TCSQL2019 1858f50a-4a7e-4a7a-b1be-d9e0d3e4ef26 Thierry     24d02310-ba6f-4...

#>


<# For the records documentation for "get  /monitoring/datadeletiondetails" on 08_17_2023 was:

https://Your_API_Server/monitoring/swaggerui/index > Safeset > Expand Operations > Model i.e.:



Response Class (Status 200)

OK

    Model
    Example Value

{
  "@odata.nextLink": "string",
  "@odata.count": 0,
  "@odata.context": "string",
  "value": [
    {
      "id": 0,
      "deletionType": "string",
      "jobId": "string",
      "jobName": "string",
      "agentId": "string",
      "agentName": "string",
      "companyId": "string",
      "companyName": "string",
      "vaultId": "string",
      "vaultName": "string",
      "safesetIds": "string",
      "vaultComputerId": "string",
      "deletionRequestedByUserId": "string",
      "deletionRequestDateUtc": "2023-08-17T08:53:26.688Z",
      "scheduledDeletionTimeUtc": "2023-08-17T08:53:26.688Z",
      "timeDeletionRequestCancelledUtc": "2023-08-17T08:53:26.688Z",
      "cancelledByUserId": "string",
      "timeJobDeletedFromPortalUtc": "2023-08-17T08:53:26.688Z",
      "timeJobDeletedFromAgentUtc": "2023-08-17T08:53:26.688Z",
      "timeAgentDeletedFromPortalUtc": "2023-08-17T08:53:26.688Z",
      "vaultDeletionRequestId": "string",
      "timeVaultDeletionRequestSentUtc": "2023-08-17T08:53:26.688Z",
      "deletedFromVault": true,
      "parentScheduledDeletionId": 0,
      "failureEvents": [
        {
          "failureType": "string",
          "failureTimeUtc": "2023-08-17T08:53:26.688Z",
          "notificationSendDateTimeUtc": "2023-08-17T08:53:26.688Z",
          "isNotificationSentSuccessfully": true
        }
      ]
    }
  ]
}

-------------------------
Parameters
Parameter 	Value 	Description 	Parameter Type 	Data Type
Authorization 		

The access token (Format: Bearer [access_token]).
	header 	string
$select 		

Properties to include in the response (Example: id,name).
	query 	string
$filter 		

Filter the response using an expression (Example: name eq 'Company Name').
	query 	string
$orderBy 		

Sort the response by one or more properties (Example: status,name).
	query 	string
$skip 		

Exclude the first n results from the response.
	query 	integer
$top 		

Include only the first n results in the response.
	query 	integer
$count 	

Include a count of results in the response.
  #>