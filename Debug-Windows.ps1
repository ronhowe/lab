# Import modules.

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter Administrator Credential" -UserName "Administrator"
$HostName = Read-Host -Prompt "Enter Host Name"

# Test WinRM to the host.
Test-NetConnection -ComputerName $HostName -Port 5985 -WarningAction SilentlyContinue

# Set Windows Firewall to allow inbound PING (ICMP).
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow }
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName "Allow inbound ICMPv6" -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow }

# Get Windows Firewall for PING (ICMP).
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock { Get-NetFirewallRule -DisplayName "Allow inbound ICMPv4" }
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock { Get-NetFirewallRule -DisplayName "Allow inbound ICMPv6" }

# PING the host.
Test-NetConnection -ComputerName $HostName -WarningAction SilentlyContinue

# Remote with WinRM.
New-PSSession -ComputerName $HostName -Credential $Credential | Enter-PSSession

# Close the remote session.
Get-PSSession | Remove-PSSession

# Reboot the host.
Restart-Computer -ComputerName $HostName -Credential $Credential -Wait -For Wmi -Force

# Get and extend evaluation licensing information.  Works only in local console session.
# https://sid-500.com/2017/08/08/windows-server-2016-evaluation-how-to-extend-the-trial-period/
slmgr -dlv
slmgr -rearm
Restart-Computer
slmgr -dli

# Set timezone.
Set-TimeZone -Name "Eastern Standard Time"
Set-TimeZone -Name "Coordinated Universal Time"

# Get timezone.
Get-TimeZone

# Download PowerShell Core.
Import-Module -Name "BitsTransfer"
$Source = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/PowerShell-7.2.4-win-x64.msi"
$Destination = "~\Downloads\PowerShell-7.2.4-win-x64.msi"
Start-BitsTransfer -Source $Source -Destination $Destination -Verbose

# Install PowerShell Core.  This will terminate the session.
Set-Location -Path "~\Downloads"
msiexec.exe /package PowerShell-7.2.4-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1

# Check for PowerShell Core.
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock { pwsh.exe --version }
