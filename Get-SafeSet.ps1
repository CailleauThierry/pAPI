<#
Get-Safeset.ps1 v 0.0.0.1 on 11/19/2018
From: Thierry Cailleau requires pAPI 1.3 . Its swagger API documentation is available under:
https://Your_API_Server/monitoring/swaggerui/index > Safeset > Expand Operations > Model
On this hostname "sys3" https://sys3/monitoring/swaggerui/index
Assumes you have registered the Vault to pAPI (dunring 8.40 upgrade or after from the cmd.exe as per Carbonite Director v8.4 - Install Guide.pdf:

C:\Director\ReportingService>.\ReportingService.exe -cmdline -register -uri https://sys3:8080 -id Carbonite-Registration-Client -secret fHYQA1byZ/X9Vb0psP62TLDA1VO38I1k5BOjJSbDkcNb
Registered vault)
#>
#Requires -Version 5
$token = (C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Token.ps1)
$url = 'https://sys3/monitoring/safesets?$count=true'
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json;api-version=1"}
$reply = Invoke-RestMethod -Uri $url -Method GET -Headers $headers

$count = $reply.'@odata.count'
$collection = $reply.value

Write-Output "We found $count safesets"

$collection | Where-Object {$_.agentName -eq 'sys3'} | Format-Table -AutoSize
$collection | Where-Object {$_.jobId -eq '2'} | Format-Table -AutoSize

<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> c:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Job.ps1


We found 1 safesets

id                                   agentId                              name description type      lastAttemptedBackupStatus lastAttemptedB
                                                                                                                               ackupTimeUtc
--                                   -------                              ---- ----------- ----      ------------------------- --------------
0e6746e5-0361-47ea-b04e-f58be9c07cb8 5efcd583-9fb3-42d1-8f69-4d5b07a60995 PFC              LocalFile Overdue                   2018-11-10T...



id                                   agentId                              name description type      lastAttemptedBackupStatus lastAttemptedB
                                                                                                                               ackupTimeUtc
--                                   -------                              ---- ----------- ----      ------------------------- --------------
0e6746e5-0361-47ea-b04e-f58be9c07cb8 5efcd583-9fb3-42d1-8f69-4d5b07a60995 PFC              LocalFile Overdue                   2018-11-10T...
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> $collection


id                                   : 0e6746e5-0361-47ea-b04e-f58be9c07cb8
agentId                              : 5efcd583-9fb3-42d1-8f69-4d5b07a60995
name                                 : PFC
description                          :
type                                 : LocalFile
lastAttemptedBackupStatus            : Overdue
lastAttemptedBackupTimeUtc           : 2018-11-10T18:34:34.8Z
lastCompletedBackupTimeUtc           : 2018-11-10T18:34:34.8Z
lastCompletedBackupOriginalSizeBytes : 22294
vaultComputerId                      : 65b5eab3-a2a8-45ca-97af-77c9302a2142
jobInfoInVaults                      : {@{vaultId=71dfc97b-8204-480f-ad39-b007c8c9b913; customerShortName=; customerLocation=; enabled=;
                                       suspect=; usedPoolSize=; physicalPoolSize=; activeOperatigMode=; baseOperatingMode=;
                                       restoresafesets=System.Object[]}}
#>


<# For the records documentation for for "get  /monitoring/safesets" on 11/14/2018 was:

https://Your_API_Server/monitoring/swaggerui/index > Safeset > Expand Operations > Model i.e.:

ODataListResponse[Safeset] {
@odata.nextLink (string, optional),

@odata.count (integer, optional): [format: int32] 
 ,

@odata.context (string, optional),

value (Array[Safeset], optional)
}Safeset {
vaultId (string, optional): [format: uuid] Unique identifier (GUID) for the vault where the safeset is stored
 ,

jobId (string, optional): [format: uuid] Unique identifier (GUID) in the vault for the safeset’s backup job
 ,

safesetNumber (integer, optional): [format: int32] Backup number of the safeset
 ,

agentId (string, optional): [format: uuid] Unique identifier (GUID) for the safeset’s agent
 ,

agentName (string, optional): Agent name
 ,

vaultComputerId (string, optional): [format: uuid] Unique identifier (GUID) in the vault for the computer where the agent is installed. If the agent did not upload the vaultComputerId to Portal, the value is null. This can occur for some older agent versions
 ,

customerShortName (string, optional): Customer/organization of the computer in the vault
 ,

customerLocation (string, optional): Customer location of the safeset’s computer in the vault
 ,

serialNumber (integer, optional): [format: int64] Serial number of safeset
 ,

parentSafesetNumber (integer, optional): [format: int32] Backup number of the job’s previous safeset
 ,

backupTime (string, optional): [format: date-time] Time that the backup started
 ,

retentionGroup (integer, optional): [format: int32] Retention group ID. A retention group is a group of safesets for a job that has the same retention settings enforced during migration
 ,

retentionOnlineSafesets (integer, optional): [format: int32] Number of safesets in the retention group that should be kept online
 ,

retentionOnlineDays (integer, optional): [format: int32] Number of days that the safeset should be kept online
 ,

retentionArchiveDays (integer, optional): [format: int32] Indicates whether/how long the safeset should be stored in offline storage. A value of zero (0) indicates that that the safeset will not be archived or stored offline
 ,

originalSizeBytes (integer, optional): [format: int64] Amount of data, in bytes, that was backed up from the computer or environment
 ,

compressedSizeBytes (integer, optional): [format: int64] Size of data, in bytes, after deltizing and compression
 ,

encrypted (boolean, optional): Specifies whether the backup data is encrypted by Backup Agent
 ,

vaultEncrypted (boolean, optional): Specifies whether the backup data has been encrypted on the vault-side, as part of the Encryption-at-Rest project
 ,

expired (boolean, optional): Specifies whether the safeset marked for deletion
 ,

status (Array[string], optional): Safeset status. Possible values are: Unknown - The status cannot be determined; Online - the safeset is online and can be restored; Secondary - the safeset has been moved out of primary storage to a secondary storage area; Offline - the safeset is archived; Invalid - the backup data format is not supported; MetadataOnly - the backup data doesn't exist on this node; Recalled - the archived safeset can be restored
 
}  #>