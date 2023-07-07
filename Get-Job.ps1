<#
Get-Job.ps1 v 0.0.0.2 on 12/20/2021
From: Thierry Cailleau requires pAPI 1.5 . Its swagger API documentation is available under:
https://Your_API_Server/monitoring/swaggerui/index > Job > Expand Operations > Model
On this hostname "papi16" https://10.9.168.97/monitoring/swaggerui/index
#>
#Requires -Version 5
$token = (C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Token.ps1)
$url = 'https://10.9.168.97/monitoring/jobs?$count=true'
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json;api-version=1"}
$reply = Invoke-RestMethod -Uri $url -Method GET -Headers $headers

$count = $reply.'@odata.count'
$collection = $reply.value

Write-Output "We found $count jobs"

$collection | Where-Object {$_.name -eq 'OraBackup'} | Format-Table -AutoSize
$collection | Where-Object {$_.agentId -eq 'a1dbed79-3886-4db5-9b0c-a2d0416b7e34'} | Format-Table -AutoSize

<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> c:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Job.ps1
We found 2 jobs

id                                   agentId                              name      description type   lastAttemptedBackupStatus lastAtt
                                                                                                                                 emptedB
                                                                                                                                 ackupTi
                                                                                                                                 meUtc
--                                   -------                              ----      ----------- ----   ------------------------- -------
4f61e4de-50f2-4229-a60f-757991474f81 9ca73a73-1842-40d7-b9cd-6f5b83c3605e OraBackup             Oracle CompletedWithErrors       2021...



id                                   agentId                              name           description type      lastAttemptedBackupStatus
--                                   -------                              ----           ----------- ----      -------------------------
493e46ef-a9e2-42b6-8382-2e95e5ae6a92 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 VaultWorkspace             LocalFile Overdue


PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI>
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