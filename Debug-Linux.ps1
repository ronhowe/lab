#requires -RunAsAdministrator

# Import module(s).
Import-Module -Name "HostsFile"
Import-Module -Name "Hyper-V"

# Get the administrator credential.
$Credential = Get-Credential -Message "Enter Administrator Credential" -UserName "administrator"

# Get the host name.
$HostName = Read-Host -Prompt "Enter Host Name"

# Get the IP address manually.
$IpAddress = Read-Host "Enter IP Address"

# Get the SSH destination.
$Destination = "$($Credential.UserName)@$IpAddress"

# Get the current time.
ssh $Destination date

# Enable guest services.  (Linux only.)
# https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
ssh -t $Destination 'sudo apt-get install linux-azure -y'

# Reboot the host.
ssh -t $Destination 'sudo reboot'

# Get IP address.  Virtual machine must be running.
[System.Net.IPAddress]$IpAddress =
Get-VMNetworkAdapter -VMName $HostName |
Select-Object -ExpandProperty "IPAddresses" |
Where-Object { $_.Length -lt 24 }
$IpAddress

# Get the SSH destination.
$Destination = "$($Credential.UserName)@$($IpAddress.IPAddressToString)"

# Update packages.
ssh -t $Destination 'sudo apt update -y'

# Upgrade packages.
ssh -t $Destination 'sudo apt upgrade -y'

# Get the host name.
ssh $Destination 'hostnamectl'

# Rename the host.
ssh $Destination 'sudo hostnamectl set-hostname "$HostName"'
#sudo reboot

# Regenerate SSH keys.
sudo /bin/rm -v /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo systemctl restart ssh

# Remove client SSH keys.
ssh-keygen -R LNX-VM

# Remote with SSH.
ssh administrator@$HostName

# Get all virtual machine IP addresses.
# Virtual machines must be running and must have guest services.
Get-VM -VMName $HostName |
Select-Object -ExpandProperty "NetworkAdapters" |
Select-Object -Property "VMName", "IPAddresses"

# Get hosts file entry.
Get-HostEntry -HostName $HostName -Section "linux"

# Remove hosts file entry.
Remove-HostEntry -HostName $HostName -Section "linux"

# Add hosts file entry.
Add-HostEntry -HostName $HostName -IpAddress $IpAddress -Section "linux" | Out-Null

# Test SSH to the host.
Test-NetConnection -ComputerName $HostName -Port 22

# Get timezone.
timedatectl
timedatectl list-timezones

# Set timezone.
sudo timedatectl set-timezone America/New_York
sudo timedatectl set-timezone Etc/UTC

# Use Secure Copy Program (scp) from WSL to copy file to the host.
scp ./OnboardingScript.sh administrator@lnx-vm:/home/administrator
