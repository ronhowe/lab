#requires -RunAsAdministrator

# Import module(s).
Import-Module -Name "Hyper-V"

# https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/setup-nat-network#create-a-nat-virtual-network

# Set the virtual switch name.
$SwitchName = "Internal Switch"

# Set the NAT name.
$NatName = "Internal NAT"

# Set the NAT gateway IP address.
$NatGatewayIpAddress = "192.168.0.1"

# Create the virtual switch.
New-VMSwitch -SwitchName $SwitchName -SwitchType Internal

# Get the virtual switch.
Get-VMSwitch -Name $SwitchName | Select-Object -Property "*"

# Create the NAT gateway IP address.
$InterfaceIndex = $(Get-NetAdapter -Name "vEthernet ($SwitchName)").ifIndex
New-NetIPAddress -IPAddress $NatGatewayIpAddress -PrefixLength 24 -InterfaceIndex $InterfaceIndex

# Get the NAT gateway IP address.
Get-NetIPAddress -IPAddress $NatGatewayIpAddress

# Create the NAT.
New-NetNat -Name $NatName -InternalIPInterfaceAddressPrefix 192.168.0.0/24

# Get the NAT.
Get-NetNat -Name $NatName

# Get the IP configuration.
Get-NetIPConfiguration | Sort-Object -Property "InterfaceAlias" | Format-Table -AutoSize

# Get all network adapters.
Get-NetAdapter | Sort-Object -Property "Name"

# Get all IPv4 addresses.
Get-NetIPAddress -AddressFamily  IPV4 | Sort-Object -Property "IPAddress" | Format-Table -AutoSize

# Get all NAT.
Get-NetNat | Sort-Object -Property "Name"

# Remove the NAT.
Remove-NetNat -Name $NatName -Confirm:$false

# Remove the NAT gateway IP address.
Remove-NetIPAddress -IPAddress $NatGatewayIpAddress -Confirm:$false

# Remove the virtual switch.
Remove-VMSwitch -Name $SwitchName -Force
