<#
Get-Vault.ps1 v 0.0.0.1 on 11/19/2018
From: Thierry Cailleau requires pAPI 1.3 . Its swagger API documentation is available under:
https://Your_API_Server/monitoring/swaggerui/index > Vault > Expand Operations > Model
On this hostname "10.9.168.97" https://10.9.168.97/monitoring/swaggerui/index
Assumes you have registered the Vault to pAPI (during 8.40 upgrade or after from the cmd.exe as per Carbonite Director v8.4 - Install Guide.pdf:

C:\Director\ReportingService>.\ReportingService.exe -cmdline -register -uri https://10.9.168.97:8080 -id Carbonite-Registration-Client -secret pEa4e4rjEfpmGLbZVqQnejVvfpa1o+s+cSeDIfTS9McH

Registered vault)
#>
#Requires -Version 5
$token = (C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Token.ps1)
$url = 'https://10.9.168.97/monitoring/vaults?$count=true'
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json;api-version=1"}
$reply = Invoke-RestMethod -Uri $url -Method GET -Headers $headers

$count = $reply.'@odata.count'
$collection = $reply.value

$collection | Format-Table -AutoSize
$reply | ConvertTo-Json -Depth 4 | Out-File -FilePath C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Vault_results.ps1.json

Write-Output "We found $count vaults"

$collection | Where-Object {$_.vaultNodesInfo.hostname -eq 'ev1'} | Format-Table -AutoSize
$collection | Where-Object {$_.vaultLicenseInfo.status -eq 'Activated'} | Format-Table -AutoSize

<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> . 'C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Vault.ps1'

id                                   vaultType     isCluster maintenanceStatus replicationTarget                    replication1To1Enabled replicationNTo1Enabled da
                                                                                                                                                                  ta
                                                                                                                                                                  ba
                                                                                                                                                                  se
                                                                                                                                                                  St
                                                                                                                                                                  at
                                                                                                                                                                  us
--                                   ---------     --------- ----------------- -----------------                    ---------------------- ---------------------- --
24d02310-ba6f-41f0-ad69-75f9dd9acae2 {BAV, Active}     False Enabled           ccaf072d-2df8-46f7-aa55-0afb21ad49a8                   True                   True Ru


We found 1 vaults
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI>
#>
<# 

C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Vault_results.ps1.json:
{
    "@odata.context":  "https://10.9.168.97/monitoring/$metadata#vaults",
    "@odata.count":  1,
    "value":  [
                  {
                      "id":  "a590ff80-345d-430e-bd55-f25b5f5fcb7d",
                      "vaultType":  [
                                        "Standalone"
                                    ],
                      "isCluster":  false,
                      "maintenanceStatus":  "Enabled",
                      "replicationTarget":  null,
                      "replication1To1Enabled":  true,
                      "replicationNTo1Enabled":  true,
                      "databaseStatus":  "Running",
                      "numReplicationSessions":  0,
                      "numReplicationEvents":  0,
                      "heartbeatFrequencyInMillisecond":  900000.0,
                      "lastHeartbeat":  "2021-12-14T22:08:43Z",
                      "vaultNodesInfo":  [
                                             {
                                                 "hostname":  "ev1",
                                                 "externalAddress":  "ev1",
                                                 "internalAddress":  "ev1",
                                                 "operatingSystem":  "Windows Server 2012 R2, 64-bit",
                                                 "state":  "Online",
                                                 "softwareVersion":  "8.51.1540",
                                                 "softwareBuildDate":  "2020-08-27T21:37:40Z",
                                                 "primaryStorageAffinity":  "None",
                                                 "status":  "Healthy",
                                                 "services":  "     "
                                             }
                                         ],
                      "satellites":  [

                                     ],
                      "customers":  [
                                        {
                                            "shortName":  "THC01",
                                            "customerInstanceName":  "THC",
                                            "customerLocations":  ""
                                        }
                                    ],
                      "storageLocations":  [
                                               {
                                                   "path":  "C:\\Vault959114148\\",
                                                   "type":  "Local",
                                                   "storageGroup":  "SG01",
                                                   "storageGroupType":  "Online",
                                                   "readOnly":  false,
                                                   "currentUsageInBytes":  48321388544,
                                                   "freeSpaceInBytes":  15734018048
                                               }
                                           ],
                      "vaultLicenseInfo":  {
                                               "status":  "Activated",
                                               "expiryDate":  "2022-01-13T00:00:00Z",
                                               "usingPerCustomerQuotas":  false,
                                               "licenseUsages":  [
                                                                     "@{type=ArchiveAgent; usage=0; quota=-1}",
                                                                     "@{type=Cluster; usage=0; quota=-1}",
                                                                     "@{type=DesktopAgent; usage=0; quota=-1}",
                                                                     "@{type=Director; usage=1; quota=1}",
                                                                     "@{type=DistributedVMWareAgentForEnterprise; usage=0; quota=0}",
                                                                     "@{type=EvaultSystemRestore; usage=0; quota=-1}",
                                                                     "@{type=ExchangeDr; usage=0; quota=-1}",
                                                                     "@{type=ExchangeMapi; usage=0; quota=-1}",
                                                                     "@{type=GranularRestoreForMsExchangeAndSql; usage=1; quota=1}",
                                                                     "@{type=ImageBackup; usage=0; quota=-1}",
                                                                     "@{type=ISeriesAgent; usage=0; quota=-1}",
                                                                     "@{type=MicrosoftDpm; usage=0; quota=-1}",
                                                                     "@{type=Oracle; usage=1; quota=-1}",
                                                                     "@{type=Otm; usage=0; quota=-1}",
                                                                     "@{type=ProtectedStorage; usage=0; quota=1024}",
                                                                     "@{type=ReplicationOneToOne; usage=1; quota=1}",
                                                                     "@{type=ReportExtractor; usage=1; quota=1}",
                                                                     "@{type=SbeAgent; usage=0; quota=-1}",
                                                                     "@{type=ServerAgent; usage=2; quota=-1}",
                                                                     "@{type=SharepointPlugin; usage=0; quota=-1}",
                                                                     "@{type=SqlServer; usage=0; quota=-1}",
                                                                     "@{type=VMWareConsolePlugin; usage=0; quota=-1}",
                                                                     "@{type=VMWareEsxCluster; usage=0; quota=-1}"
                                                                 ]
                                           },
                      "maintenanceHostProgress":  {
                                                      "runningJobs":  0,
                                                      "waitingJobs":  0,
                                                      "pendingJobs":  0
                                                  },
                      "replicationSessions":  [

                                              ]
                  }
              ]
}
#>

<# For the records documentation for for "get  /monitoring/vaults" on 11/14/2018 was:

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

retentionGroup (integer, optional): [format: int32] Retention group ID. A retention group is a group of vaults for a job that has the same retention settings enforced during migration
 ,

retentionOnlinevaults (integer, optional): [format: int32] Number of vaults in the retention group that should be kept online
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