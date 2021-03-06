# Import module(s).
Import-Module -Name "Hyper-V"

# Get the administrator credential.
$Credential = Get-Credential -Message "Enter Administrator Credential" -UserName "Administrator"

# Get the host name.
$HostName = Read-Host -Prompt "Enter Host Name"

# Get the host name.
Invoke-Command -VMName $HostName -Credential $Credential -ScriptBlock { hostname }

# Rename the host.
Invoke-Command -VMName $HostName -Credential $Credential -ScriptBlock { Rename-Computer -NewName $using:HostName -Restart -Force }

# Get the IP address.
$IpAddress = Read-Host -Prompt "Enter IP Address" # 192.168.0.10

# Get the Gateway IP address.
$GatewayIpAddress = Read-Host -Prompt "Enter Gateway IP Address" # 192.168.0.1

# Get the DNS IP addresses.
$PrimaryDnsIpAddress = Read-Host -Prompt "Enter Primary DNS IP Address" # 192.168.0.10
$SecondaryDnsIpAddress = Read-Host -Prompt "Enter Secondary DNS IP Address" # 192.168.1.1

# Set a static IP address.
$ScriptBlock = {
    $InterfaceIndex = $(Get-NetAdapter -Name "Ethernet").ifIndex
    Remove-NetIPAddress -InterfaceIndex $InterfaceIndex -Confirm:$false
    Remove-NetRoute -InterfaceIndex $InterfaceIndex -Confirm:$false
    New-NetIPAddress -IPAddress $using:IpAddress -AddressFamily IPv4 -PrefixLength "24" -InterfaceIndex $InterfaceIndex -DefaultGateway $using:GatewayIpAddress | Out-Null
    Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses ($using:PrimaryDnsIpAddress, $using:SecondaryDnsIpAddress) | Out-Null
    Start-Sleep -Seconds 5
    Test-NetConnection
}
Invoke-Command -VMName $HostName -Credential $Credential -ScriptBlock $ScriptBlock

# Test WinRM to the host.
Test-NetConnection -ComputerName $HostName -Port 5985 -WarningAction SilentlyContinue

# Create a PowerShell session over WinRM.
$Session = New-PSSession -ComputerName $HostName -Credential $Credential

# Check the session.
$Session | Get-PSSession

# Enter the session.
$Session | Enter-PSSession

# Close the session.
$Session | Remove-PSSession

# Set Windows Firewall to allow inbound PING (ICMP).
$ScriptBlock = {
    New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
    New-NetFirewallRule -DisplayName "Allow inbound ICMPv6" -Direction Inbound -Protocol ICMPv6 -IcmpType 8 -Action Allow
}
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock $ScriptBlock

# Get Windows Firewall for PING (ICMP).
$ScriptBlock = {
    Get-NetFirewallRule -DisplayName "Allow inbound ICMPv4"
    Get-NetFirewallRule -DisplayName "Allow inbound ICMPv6"
}
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock $ScriptBlock

# PING the host.
Test-NetConnection -ComputerName $HostName -WarningAction SilentlyContinue

# Get timezone.
$ScriptBlock = {
    Get-TimeZone
}
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock $ScriptBlock

# Set timezone.
$ScriptBlock = {
    Set-TimeZone -Name "Coordinated Universal Time"
    # Set-TimeZone -Name "Eastern Standard Time"
}
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock $ScriptBlock

# Download PowerShell Core.
$ScriptBlock = {
    Import-Module -Name "BitsTransfer"
    $Source = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/PowerShell-7.2.4-win-x64.msi"
    $Destination = "~\Downloads\PowerShell-7.2.4-win-x64.msi"
    Start-BitsTransfer -Source $Source -Destination $Destination -Verbose
}
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock $ScriptBlock

# Install PowerShell Core.  This will terminate the session.
$ScriptBlock = {
    Set-Location -Path "~\Downloads"
    msiexec.exe /package PowerShell-7.2.4-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1
}
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock $ScriptBlock

# Check for PowerShell Core.
Invoke-Command -ComputerName $HostName -Credential $Credential -ScriptBlock { pwsh.exe --version }

# Get and extend evaluation licensing information.  Works only in local console session.
# https://sid-500.com/2017/08/08/windows-server-2016-evaluation-how-to-extend-the-trial-period/
# slmgr -dlv
# slmgr -rearm
# Restart-Computer
# slmgr -dli

# Reboot the host.
Restart-Computer -ComputerName $HostName -Credential $Credential -Wait -For Wmi -Force
