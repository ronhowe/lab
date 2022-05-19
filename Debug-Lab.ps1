#requires -RunAsAdministrator

# Configure preferences.
$ProgressPreference = "SilentlyContinue"

# Import module(s).
Import-Module -Name "Hyper-V"

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter Administrator Credential"
$ComputerName = "WINDOWS"

# TODO Create Virtual Machine

# Get the computer name.
Invoke-Command -VMName $ComputerName -Credential $Credential -ScriptBlock { hostname }

# Rename the computer.
Invoke-Command -VMName $ComputerName -Credential $Credential -ScriptBlock { Rename-Computer -NewName $using:ComputerName -Restart -Force }

# Allow PING (ICMP) through the Windows Firewall.
Invoke-Command -VMName $ComputerName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName “Allow inbound ICMPv4” -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow }
Invoke-Command -VMName $ComputerName -Credential $Credential -ScriptBlock { New-NetFirewallRule -DisplayName “Allow inbound ICMPv6” -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow }

# PING the computer.
Test-NetConnection -ComputerName $ComputerName -WarningAction SilentlyContinue

# Get a remote session to the computer.
$Session = New-PSSession -ComputerName $ComputerName -Credential $Credential

# Enter remote session.
Enter-PSSession -Session $Session

# Close the remote session.
Remove-PSSession -Session $Session

# Reboot the computer.
Restart-Computer -ComputerName $ComputerName -Credential $Credential -Force -Wait
