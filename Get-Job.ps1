<#
Get-Job.ps1 v 0.0.0.1 on 11/19/2018
From: Thierry Cailleau requires pAPI 1.3 . Its swagger API documentation is available under:
https://Your_API_Server/monitoring/swaggerui/index > Job > Expand Operations > Model
On this hostname "sys3" https://sys3/monitoring/swaggerui/index
#>
#Requires -Version 5
$token = (C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Token.ps1)
$url = 'https://sys3/monitoring/jobs?$count=true'
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json;api-version=1"}
$reply = Invoke-RestMethod -Uri $url -Method GET -Headers $headers

$count = $reply.'@odata.count'
$collection = $reply.value

Write-Output "We found $count jobs"

$collection | Where-Object {$_.name -eq 'PFC'} | Format-Table -AutoSize
$collection | Where-Object {$_.agentId -eq '5efcd583-9fb3-42d1-8f69-4d5b07a60995'} | Format-Table -AutoSize

<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> c:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Job.ps1


We found 1 jobs

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
                                       restoreJobs=System.Object[]}}
#>


<# For the records documentation for for "get  /monitoring/jobs" on 11/14/2018 was:

https://Your_API_Server/monitoring/swaggerui/index > Job> Expand Operations > Model i.e.:

ODataListResponse[Job] {
@odata.nextLink (string, optional),

@odata.count (integer, optional): [format: int32] 
 ,

@odata.context (string, optional),

value (Array[Job], optional)
}Job {
id (string, optional): [format: uuid] Unique identifier (GUID) for a backup job in the vault. This GUID is automatically generated when a job is created in the vault
 ,

agentId (string, optional): [format: uuid] Unique identifier (GUID) in Portal for the job’s Agent
 ,

name (string, optional): Name of the job
 ,

description (string, optional): Job description
 ,

type (string, optional): Job type. Type: Local System, UNC File, SQL Server etc [BadJobFormat, Dpm, Exchange, Exchange2010, ExchangeVss, ExchangeMapi, LocalFile, MappedFile, Nfs, Oracle, OracleRman, SharePoint, SqlServer2012, SqlServer, Unc, Undefined, Vault, VMWare, VSphere, VolumeImage, HyperV, SystemVolume, VDA]
 ,

lastAttemptedBackupStatus (string, optional): Status of the last attempted backup [Unknown, Completed, Failed, Cancelled, Incomplete, NeverRun, CompletedWithErrors, CompletedWithWarnings, Overdue, Undefined, FailedLoad, Deferred, DeferredWithErrors, DeferredWithWarnings, NoFiles, LicenseLimit, InProgress, Missed]
 ,

lastAttemptedBackupTimeUtc (string, optional): [format: date-time] Last date and time when the backup job ran. If the job has not run, the value is null
 ,

lastCompletedBackupTimeUtc (string, optional): [format: date-time] Last date and time when the backup job completed successfully. The job might have completed with errors or with warnings. If the job has not completed successfully, the value is null
 ,

lastCompletedBackupOriginalSizeBytes (integer, optional): [format: int64] Amount of data, in bytes, that was backed up from the computer or environment in the last successful backup. If the job has not completed successfully, the value is null
 ,

vaultComputerId (string, optional): [format: uuid] Unique identifier (GUID) in the vault for the computer where the agent is installed. This GUID is automatically generated when an agent registers to a vault. If the agent did not upload the vaultComputerId to Portal, the value is null. This can occur for some older agent versions
 ,

jobInfoInVaults (Array[JobInfoInVaults], optional): Job information in Vaults
 
}JobInfoInVaults {
vaultId (string, optional): [format: uuid] Unique identifier (GUID) for the vault where the job’s backup data is stored. If the vault GUID is not saved in Portal, the value is null
 ,

customerShortName (string, optional): Shortname of the customer/organization in the vault
 ,

customerLocation (string, optional): The customer/organization's locations in the vault
 ,

enabled (boolean, optional): If true, the job is enabled and agent can back up data associated with that job to and restore data from the vault. If false, the job is disabled and agent cannot back up data to or restore data from the vault
 ,

suspect (boolean, optional): If true, the job is marked as suspected and agent cannot back up data associated with that job to and restore data from the vault.
 ,

usedPoolSize (integer, optional): [format: int64] The pool size used by this job
 ,

physicalPoolSize (integer, optional): [format: int64] The physical size of data associated with thatjob
 ,

activeOperatigMode (string, optional): indicated how Replication handles this Job on Active Vault[Unknown, Normal, PauseReplication, BypassSatellite]
 ,

baseOperatingMode (string, optional): indicated how Replication handles this Job on Base Vault[Unknown, Normal, PauseReplication, BypassSatellite]
 ,

restoreJobs (Array[RestoreJob], optional): Status of the last attempted restores. Foe more information see RestoreJob
 
}RestoreJob {
restoreTime (string, optional): [format: date-time] Restore Time
 ,

restoreStatus (string, optional): Restore Status[Unknown, Success, Failure]
 
} 

} #>