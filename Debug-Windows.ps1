# Configure preferences.
$ProgressPreference = "SilentlyContinue"

# Import modules.

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter Administrator Credential" -UserName "Administrator"
$ComputerName = Read-Host -Prompt "Enter Computer Name"

# PING the computer.
Test-NetConnection -ComputerName $ComputerName -Port 5985 -WarningAction SilentlyContinue

# Set Windows Firewall for PING (ICMP).
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow }
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName "Allow inbound ICMPv6" -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow }

# Get Windows Firewall for PING (ICMP).
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Get-NetFirewallRule -DisplayName "Allow inbound ICMPv4" }
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { Get-NetFirewallRule -DisplayName "Allow inbound ICMPv6" }

# PING the computer.
Test-NetConnection -ComputerName $ComputerName -WarningAction SilentlyContinue

# Get a remote session to the computer.
New-PSSession -ComputerName $ComputerName -Credential $Credential | Enter-PSSession

# Close the remote session.
Get-PSSession | Remove-PSSession

# Reboot the computer.
Restart-Computer -ComputerName $ComputerName -Credential $Credential -Wait -For Wmi -Force

# Get and extend evaluation licensing information.  Works only in local console session.
# https://sid-500.com/2017/08/08/windows-server-2016-evaluation-how-to-extend-the-trial-period/
slmgr -dlv
slmgr -rearm
Restart-Computer
slmgr -dli


Set-TimeZone -Name "Eastern Standard Time"
Set-TimeZone -Name "Coordinated Universal Time"

# https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell

$url = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/PowerShell-7.2.4-win-x64.msi"
$output = "~\Downloads\PowerShell-7.2.4-win-x64.msi"
Import-Module -Name "BitsTransfer"
Start-BitsTransfer -Source $url -Destination $output -verbose
Start-BitsTransfer -Source $url -Destination $output -Asynchronous

Set-Location -Path "~\Downloads"
msiexec.exe /package PowerShell-7.2.4-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1
