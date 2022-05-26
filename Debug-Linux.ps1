# Import module(s).
Import-Module -Name "Hyper-V"

# Get the administrator credential.
$Credential = Get-Credential -Message "Enter Administrator Credential" -UserName "administrator"

# Get the username.
$UserName = $Credential.UserName

# Get the host name.
$HostName = Read-Host -Prompt "Enter Host Name"

# Get the IP address manually.
$IpAddress = Read-Host "Enter IP Address"

# Get the SSH destination.
$Destination = "$UserName@$IpAddress"

# Get the current time.
ssh $Destination date

# Enable guest services.  (Linux only.)
# https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
ssh -t $Destination 'sudo apt-get install linux-azure -y'

# Reboot the host.
ssh -t $Destination 'sudo reboot'

# Get IP address.  Virtual machine must be running.
function Get-VmIpAddressAddress {
    param(
        [string]
        $VMName
    )
    [System.Net.IPAddress]$IpAddress =
    Get-VMNetworkAdapter -VMName $HostName |
    Select-Object -ExpandProperty "IPAddresses" |
    Where-Object { $_.Length -lt 24 }
    return $IpAddress.IPAddressToString
}

$IpAddress = Get-VmIpAddressAddress -VMName $HostName

# Get the SSH destination.
$Destination = "$UserName@$IpAddress"

# SSH to host.
ssh $Destination

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

# https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-7.2
sudo find -name "pwsh"

Subsystem powershell /snap/bin/pwsh -sshs -NoLogo

sudo systemctl restart sshd.service

$Session = New-PSSession -HostName 172.26.114.202 -UserName administrator
