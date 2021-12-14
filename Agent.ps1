<#
From: Thierry Cailleau on 11/14/2018 based on pAPI 1.3 swagger API documentation available under:
https://Your_API_Server/monitoring/swaggerui/index > Agent > Expand Operations > Model
#>
$token = (C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Get-Token.ps1)
$url = 'https://papi16.test.local/monitoring/agents?$count=true'
$headers = @{"Authorization"="Bearer $token";"Accept"="application/json;api-version=1"}
$reply = Invoke-RestMethod -Uri $url -Method GET -Headers $headers

$count = $reply.'@odata.count'
$collection = $reply.value

Write-Output "We found $count agents"

$collection | Where-Object {$_.Name -eq 'ev1'} | Format-Table -AutoSize
$collection | Where-Object {$_.availability -eq 'offline'} | Format-Table -AutoSize

<#
PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI> c:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI\Agent.ps1
We found 2 agents

id                                   companyId                            name description version   operatingSystem             hostName agentType status availability
--                                   ---------                            ---- ----------- -------   ---------------             -------- --------- ------ ------------
a1dbed79-3886-4db5-9b0c-a2d0416b7e34 6a7ddad3-a15b-462e-9423-9110a0c93ad9 EV1              8.72.1010 Windows Server 2012 R2 x64  EV1      SERVER    Errors Online



id                                   companyId                            name  description version   operatingSystem          hostName agentType status availability
--                                   ---------                            ----  ----------- -------   ---------------          -------- --------- ------ ------------
9ca73a73-1842-40d7-b9cd-6f5b83c3605e 6a7ddad3-a15b-462e-9423-9110a0c93ad9 ORA16             9.00.1012 Windows Server 2016 x64  ORA16    SERVER    Errors Offline


PS C:\Users\Administrator\Documents\WindowsPowerShell\Scripts\pAPI>
#>
<# For the records documentation for for "get  /monitoring/agents" on 11/14/2018 was:

https://Your_API_Server/monitoring/swaggerui/index > Agent > Expand Operations > Model i.e.:
ODataListResponse[Agent] {
@odata.nextLink (string, optional),

@odata.count (integer, optional): [format: int32]
 ,

@odata.context (string, optional),

value (Array[Agent], optional)
}Agent {
id (string, optional): [format: uuid] Unique identifier (GUID) for an agent in Portal. This GUID is automatically generated when an agent registers to Portal
 ,

companyId (string, optional): [format: uuid] Unique identifier (GUID) for the agent’s company
 ,

name (string, optional): Agent name
 ,

description (string, optional): Agent description
 ,

version (string, optional): Agent version
 ,

operatingSystem (string, optional): Operating system of the computer where the agent is installed
 ,

hostName (string, optional): Name of the computer where the agent is installed
 ,

status (string, optional): Agent status. Possible values are: Unconfigured - No jobs have been created for the agent; Errors - One or more of the agent's jobs failed or completed with errors; Warnings - One or more of the agent's jobs completed with warnings; OK - The agent's job or jobs ran without errors or warnings[Unconfigured, Errors, Warnings, Ok]
 ,

availability (string, optional): Agent availability. Possible values are: Online - The agent is in contact with Portal; Offline - The agent has not contacted Portal for more than 90 seconds; Reboot - The agent is in contact with Portal. There is a pending reboot on the agent computer; Deleted - The agent has been marked as deleted in Portal[Online, Offline, Reboot, Deleted]
 ,

vaultRegistrations (Array[VaultRegistration], optional): The agent's vault registrations. For more information, see VaultRegistration below
 ,

bandwidthThrottlingSettings (AgentBandwidthThrottlingSettings, optional): Agent's bandwidth throttling settings. For more information, see AgentBandwidthThrottlingSettings below
 ,

numberOfJobs (integer, optional): [format: int32] Number of backup jobs on the agent
 ,

deferredJobStatus (DeferredJobStatus, optional): Deferred backup jobs. When deferring is enabled, no new data is backed up in a job after a specified amount of time even if the backup is not complete
 ,

schedulerEnabled (boolean, optional): If true, the agent scheduler is enabled
 ,

lastPresentUtc (string, optional): [format: date-time] Last time the agent contacted Portal
 ,

agentPluginSettings (Array[AgentPluginSetting], optional): Plugins installed with the agent. For more information, see pluginName below

}VaultRegistration {
vaultComputerId (string, optional): [format: uuid] Unique identifier (GUID) in the vault for the computer where the agent is installed. This GUID is automatically generated when an agent registers to a vault. If the agent did not upload the vaultComputerId to Portal, the value is null. This can occur for some older agent versions
 ,

agentInfoInVaults (Array[VaultComputer], optional): Agent information from associated vaults

}AgentBandwidthThrottlingSettings {
daysOfWeek (string, optional): Days of the week when bandwidth is limited
 ,

enabled (boolean, optional): If true, bandwidth throttling is enabled on specified days and times
 ,

startTime (string, optional): Start time of bandwidth throttling. The time is the local time of the computer where the agent is installed
 ,

endTime (string, optional): End time of bandwidth throttling. The time is the local time of the computer where the agent is installed
 ,

maxBandwidthBps (integer, optional): [format: int32] Maximum bandwidth in bits per second when bandwidth throttling is enabled
 ,

createdOnUtc (string, optional): [format: date-time] Date and time when the bandwidth throttling settings were created

}DeferredJobStatus {
numberOfDeferredJobs (integer, optional): [format: int32] Number of agent jobs that were deferred (i.e., partially backed up)
 ,

numberOfSuccessfulDeferredJobs (integer, optional): [format: int32] Number of agent jobs that were deferred without warnings or errors
 ,

numberOfDeferredJobsWithErrors (integer, optional): [format: int32] Number of agent jobs that were deferred with errors
 ,

numberOfDeferredJobsWithWarnings (integer, optional): [format: int32] Number of agent jobs that were deferred with warnings

}AgentPluginSetting {
pluginName (string, optional): Plugin installed with the agent

}VaultComputer {
vaultId (string, optional): [format: uuid] Unique identifier (GUID) for a vault where the computer is registered with the specified VaultComputerId
 ,

computerName (string, optional): Name of the computer in the vault
 ,

customerShortName (string, optional): Customer/organization of the computer in the vault
 ,

customerLocation (string, optional): Customer location of the computer in the vault
 ,

agentSystemName (string, optional): System name of the computer in the vault
 ,

agentDomain (string, optional): Domain of the computer in the vault
 ,

agentNetworkAddress (string, optional): Network address of the computer in the vault
 ,

agentOsType (string, optional): Operating system type of the computer in the vault
 ,

agentOsVersion (string, optional): Operating system version of the computer in the vault
 ,

agentType (string, optional): Type of agent installed on the computer
 ,

agentVersion (string, optional): Version of the agent installed on the computer

} #>