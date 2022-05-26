#requires -RunAsAdministrator

# Import modules.
Import-Module -Name "Hyper-V"

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter Administrator Credential"
$HostName = Read-Host -Prompt "Enter Host Name"
$VhdPath = "D:\Hyper-V\Virtual Hard Disks\$HostName.vhdx"
$IsoPath = "C:\Users\ronhowe\Downloads\LAB\Windows Server 2022.iso"
$SwitchName = "Default Switch"

# Create the virtual hard disk.
New-VHD -Path $VhdPath -SizeBytes 127GB -Dynamic

# Get the virtual hard disk.
Get-VHD -Path $VhdPath

# Create the virtual machine.
New-VM -Name $HostName -MemoryStartupBytes 4GB -VHDPath $VhdPath -SwitchName $SwitchName -Generation 2

# Get the virtual machine.
Get-VM -VMName $HostName

# Set the processor count.
Set-VM -VMName $HostName -ProcessorCount 4

# Disable automatic checkpoints.
Set-VM -Name $HostName -AutomaticCheckpointsEnabled $false

# Enable guest services.  Windows only.
Enable-VMIntegrationService -VMName $HostName -Name "Guest Service Interface"

# Add DVD drive with mounted ISO.
Add-VMDvdDrive -VMName $HostName -Path $IsoPath

# Set device boot order.
Set-VMFirmware -VMName $HostName -FirstBootDevice $(Get-VMDvdDrive -VMName $HostName)

# Get device boot order.
Get-VMFirmware -VMName $HostName | Select-Object -ExpandProperty "BootOrder"

# Start the virtual machine.
Start-VM -VMName $HostName

# Finish OOBE setup.
vmconnect.exe localhost $HostName

# Rename the host.
Invoke-Command -VMName $HostName -Credential $Credential -ScriptBlock { Rename-Computer -NewName $using:HostName -Restart -Force }

# Get the host name.
Invoke-Command -VMName $HostName -Credential $Credential -ScriptBlock { hostname }

# Get all virtual machine IP addresses.
# Virtual machines must be running and must have guest services.
Get-VM -VMName $HostName |
Select-Object -ExpandProperty "NetworkAdapters" |
Select-Object -Property "VMName", "IPAddresses"

# Stop the virtual machine gracefully.
Stop-VM -VMName $HostName

# Stop the virtual machine forcefully.
Stop-VM -VMName $HostName -Force

# Checkpoint the virtual machine.
Checkpoint-VM -VMName $HostName -SnapshotName "BASE"

# Remove the virtual machine.
Remove-VM -VMName $HostName -Force

# Remove the virtual hard disk.
Remove-Item -Path $VhdPath -Force
