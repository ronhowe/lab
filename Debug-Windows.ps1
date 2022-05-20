# Configure preferences.
$ProgressPreference = "SilentlyContinue"

# Import modules.

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter Administrator Credential" -UserName "Administrator"
$ComputerName = Read-Host -Prompt "Enter Computer Name"

# Allow PING (ICMP) through the Windows Firewall.
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName “Allow inbound ICMPv4” -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow }
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName “Allow inbound ICMPv6” -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow }

# PING the computer.
Test-NetConnection -ComputerName $ComputerName -WarningAction SilentlyContinue

# Get a remote session to the computer.
New-PSSession -ComputerName $ComputerName -Credential $Credential | Enter-PSSession

# Close the remote session.
Get-PSSession | Remove-PSSession

# Reboot the computer.
Restart-Computer -ComputerName $ComputerName -Credential $Credential -Wait -For Wmi -Force
