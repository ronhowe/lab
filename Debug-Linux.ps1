#requires -RunAsAdministrator

# Import module(s).
Import-Module -Name "Hyper-V"

# Get the administrator credential.
$Credential = Get-Credential -Message "Enter Administrator Credential" -UserName "administrator"

# Get the username.
$UserName = $Credential.UserName

# Get the host name.
$HostName = Read-Host -Prompt "Enter Host Name"

# Get the IP address.
$IpAddress = "192.168.0.3" # Standardized static IP.

# Get the SSH destination by IP address.
$Destination = "$UserName@$IpAddress"

# Get the hostname.
ssh $Destination hostname

# Update packages.
ssh -t $Destination "sudo apt update -y"

# Upgrade packages.
ssh -t $Destination "sudo apt upgrade -y"

# Enable guest services.
# https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
ssh -t $Destination "sudo apt-get install linux-azure -y"

# Reboot the host.
ssh -t $Destination "sudo reboot"

# Get the host name.
ssh $Destination "hostnamectl"

# Rename the host.  Reboot after.
ssh -t $Destination "sudo hostnamectl set-hostname $HostName"

# Regenerate SSH keys.
# These must be run locally because they terminate and eliminate SSH connectivity.
# sudo /bin/rm -v /etc/ssh/ssh_host_*
# sudo dpkg-reconfigure openssh-server
# sudo systemctl restart ssh

# Remove client SSH keys.
ssh-keygen -R $IpAddress
ssh-keygen -R $HostName

# Test SSH to the host by IP address.
Test-NetConnection -ComputerName $IpAddress -Port 22

# Get the hosts file entry.
Get-Content -Path "C:\Windows\System32\drivers\etc\hosts" | Select-String -SimpleMatch "LNX-VM"

# Test SSH to the host by host name.  Requires hosts file entry.
Test-NetConnection -ComputerName $HostName -Port 22

# Get the SSH destination by host name.
$Destination = "$UserName@$HostName"

# Get the hostname.
ssh $Destination hostname

# Get the current time.
ssh $Destination date

# Get timezone.
ssh $Destination "timedatectl"

# Get timezone.
ssh $Destination "timedatectl"

# Get supported timezones.
ssh $Destination "timedatectl list-timezones"

# Set timezone.
ssh $Destination "sudo timedatectl set-timezone Etc/UTC"
# ssh $Destination "sudo timedatectl set-timezone America/New_York"

# https://docs.microsoft.com/en-us/powershell/scripting/learn/remoting/ssh-remoting-in-powershell-core?view=powershell-7.2
ssh $Destination

# cd /
# sudo find -name "pwsh"
# sudo nano /etc/ssh/sshd_config
# # paste
# Subsystem powershell /snap/bin/pwsh -sshs -NoLogo
# sudo systemctl restart sshd.service

# Create a PowerShell session over SSH.
$Session = New-PSSession -HostName $HostName -UserName administrator

# Get the session.
$Session | Get-PSSession

# Enter the session.
$Session | Enter-PSSession

# Close the session.
$Session | Remove-PSSession

# Use Secure Copy Program (scp) from WSL to copy file to the host.
scp ./OnboardingScript.sh administrator@LNX-VM:/home/administrator
