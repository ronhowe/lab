# Configure preferences.
$ProgressPreference = "SilentlyContinue"

# Import modules.
Import-Module -Name "Hyper-V"

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter Administrator Credential"
$ComputerName = Read-Host -Prompt "Enter Computer Name"

# Allow PING (ICMP) through the Windows Firewall.
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName “Allow inbound ICMPv4” -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow }
Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName “Allow inbound ICMPv6” -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow }

# PING the computer.
Test-NetConnection -ComputerName $ComputerName -WarningAction SilentlyContinue

# Get a remote session to the computer.
$Session = New-PSSession -ComputerName $ComputerName -Credential $Credential

# Enter remote session.
Enter-PSSession -Session $Session

# Close the remote session.
Remove-PSSession -Session $Session

# Reboot the computer.
Restart-Computer -ComputerName $ComputerName -Credential $Credential -Wait -For Wmi -Force
