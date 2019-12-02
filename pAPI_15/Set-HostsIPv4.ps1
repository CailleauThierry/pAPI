<#	
	.NOTES
	===========================================================================
	 Created with: VSCode Version: 1.40.1 (system setup)
		Commit: 8795a9889db74563ddd43eb0a897a2384129a619
		Date: 2019-11-13T16:49:35.976Z
		Electron: 6.1.2
		Chrome: 76.0.3809.226
		Node.js: 12.4.0
		V8: 7.6.303.31-electron.0
		OS: Windows_NT x64 6.3.9600
	 Created on:   	11_25_2019 8:51 AM
	 Created by:   	Thierry Cailleau
	 Organization: 	
	 Filename:     	Set-HostsIPv4.ps1 
	===========================================================================
	.DESCRIPTION
		Set-HostsIPv4.ps1 v1.0 (from Set-AmpProxyServiceIPv4.ps1):
	This version 1.0 checks where hosts file is installed on the current machine and if it exist there, on top of changing the IPV4 with the current one in that file
		Set-HostsIPv4.ps1 pre-v1.0:
	I have installed an a single test VM:
	- UI Portal 8.83
	- Director Vault 8.50
	- pAPI 1.5
	- Agent 8.71
#>

Get-Service -Name KeyCloak | Stop-Service

# Find Where "hosts file" is located

$A = Get-Item -Path HKLM:\SOFTWARE\Wow6432Node\EVault\InfoStage\Portal\
$HostsDir = "$env:SystemDrive\Windows\System32\Drivers\etc"
$HostsExeConfigPath = $HostsDir + '\' + 'hosts'

if (Test-Path $HostsExeConfigPath){
	# Expand each line of "hosts file" into an array stored into a variable $Hosts
	$Hosts = Get-Content $HostsExeConfigPath
	# Takes line 22 (starting at 0 for an array, i.e. really line 23) of the "hosts file"
	# Example of line 23:     <add key="Proxy.Agent.Listen.IpAddress" value="192.168.47.127" />
	$OldLine = ($Hosts)[22]
	# Finds everthing before and after 'value="' and capture the one before last result, here the full IP address 192.168.47.127
	[string]$IPadd = ($Hosts)[22].Split(' ')[0]
	# uses ipconfig lines (filetered to contain keyword IPv4) and get the last entry after ' : '
	[string]$IPNow = (ipconfig | findstr IPv4).Split(' : ')[-1]
	# replaces old IP by current IP in line 23
	[string]$NewLine = ($Hosts)[22].Replace("$IPadd", "$IPNow")
	# replaces line 23 in "hosts file" variable $Hosts then write the content of this to hosts file (-Force is to replace the whole file's content)
	$Hosts.Replace("$OldLine", "$NewLine") | Out-File -FilePath $HostsExeConfigPath -Force
	# Restart KeyCloak Service first
	Get-Service -Name KeyCloak |  Start-Service
	# tested to work with PS v5.1 (pAPI Requirement)
}
else{
	# Test if hosts file exists. If not bypasses the script and just writes an Output Error Message
	Write-Output "hosts file was not found in Psth: $HostsDir"
}
