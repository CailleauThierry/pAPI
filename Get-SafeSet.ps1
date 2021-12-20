<#
Get-Safeset.ps1 v 0.0.0.2 on 12/20/2021
From: Thierry Cailleau requires pAPI 1.5 . Its swagger API documentation is available under:
https://Your_API_Server/monitoring/swaggerui/index > Safeset > Expand Operations > Model
On this hostname "papi16" https://papi16.test.local/monitoring/swaggerui/index
Assumes you have registered the Vault to pAPI (dunring 8.40 upgrade or after from the cmd.exe as per Carbonite Director v8.4 - Install Guide.pdf:

C:\Director\ReportingService>.\ReportingService.exe -cmdline -register -uri https://sys3:8080 -id Carbonite-Registration-Client -secret fHYQA1byZ/X9Vb0psP62TLDA1VO38I1k5BOjJSbDkcNb
Registered vault)
#>
#Requires -Version 5
$token = (C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Token.ps1)
$url = 'https://papi16.test.local/monitoring/safesets?$count=true'
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json;api-version=1"}
$reply = Invoke-RestMethod -Uri $url -Method GET -Headers $headers

$count = $reply.'@odata.count'
$collection = $reply.value

Write-Output "We found $count safesets"

$collection | Where-Object {$_.agentName -eq 'EV1'} | Format-Table -AutoSize
$collection | Where-Object {$_.jobId -eq '4f61e4de-50f2-4229-a60f-757991474f81'} | Format-Table -AutoSize

<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> c:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-SafeSet.ps1
We found 29 safesets

vaultId                              jobId                                safesetNumber agentId                              agentName vaultComputerId                      customerShortName customerLocation serialNumber parentSafesetNumber
-------                              -----                                ------------- -------                              --------- ---------------                      ----------------- ---------------- ------------ -------------------
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             1 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           4159309955                   0
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             2 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2355365693                   0
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             3 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2192810929                   2
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             4 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2245529755                   3
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             5 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2255352016                   4
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             6 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2276905046                   5
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             7 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2270923223                   6
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             8 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2267996901                   7
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92             9 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268878443                   8
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            10 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268404682                   9
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            11 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268079562                  10
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            12 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268942282                  11
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            13 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268636922                  12
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            14 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268756556                  13
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            15 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268842951                  14
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            16 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268816294                  15
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            17 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268796462                  16
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            18 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268911440                  17
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            19 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2269060870                  18
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            20 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2269025725                  19
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            21 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2269093583                  20
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            22 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2269065944                  21
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            23 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268917978                  22
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            24 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268947052                  23
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            25 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2268941022                  24
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            26 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2274084118                  25
a590ff80-345d-430e-bd55-f25b5f5fcb7d 493e46ef-a9e2-42b6-8382-2e95e5ae6a92            27 a1dbed79-3886-4db5-9b0c-a2d0416b7e34 EV1       577e2916-6124-412b-bc89-bdf3c3eaa24c THC01             DenBosch           2278603468                  26



vaultId                              jobId                                safesetNumber agentId                              agentName vaultComputerId                      customerShortName customerLocation serialNumber parentSafesetNumber
-------                              -----                                ------------- -------                              --------- ---------------                      ----------------- ---------------- ------------ -------------------
a590ff80-345d-430e-bd55-f25b5f5fcb7d 4f61e4de-50f2-4229-a60f-757991474f81             1 9ca73a73-1842-40d7-b9cd-6f5b83c3605e ORA16     e3fb89ee-5333-42bb-aa53-d242f2bfd226 THC01             DenBosch           3351688135                   0
a590ff80-345d-430e-bd55-f25b5f5fcb7d 4f61e4de-50f2-4229-a60f-757991474f81             2 9ca73a73-1842-40d7-b9cd-6f5b83c3605e ORA16     e3fb89ee-5333-42bb-aa53-d242f2bfd226 THC01             DenBosch           2764008692                   1


PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI>
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