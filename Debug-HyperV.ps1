#requires -RunAsAdministrator

# Import module(s).
Import-Module -Name "Hyper-V"

# Get the operating system.
$OperatingSystem = Read-Host -Prompt "(L)inux or (W)indows"

# Get the ISO path.
$IsoPath =
switch ($OperatingSystem) {
    "L" { "C:\Users\ronhowe\Downloads\LAB\ubuntu-20.04.4-live-server-amd64.iso" }
    "W" { "C:\Users\ronhowe\Downloads\LAB\Windows Server 2022.iso" }
    default { throw }
}

# Get the virtual machine name.
$VMName = Read-Host -Prompt "Enter Virtual Machine Name"

# Get the virtual hard drive path.
$VhdPath = "D:\Hyper-V\Virtual Hard Disks\$VMName.vhdx"

# Set the virtual switch name.
$SwitchName = "Internal Switch"

# Create the virtual hard disk.
New-VHD -Path $VhdPath -SizeBytes 127GB -Dynamic

# Create the virtual machine.
New-VM -Name $VMName -MemoryStartupBytes 4GB -VHDPath $VhdPath -SwitchName $SwitchName -Generation 2

# Set the processor count.
Set-VM -VMName $VMName -ProcessorCount 4

# Disable automatic checkpoints.
Set-VM -Name $VMName -AutomaticCheckpointsEnabled $false

# Enable guest services.
Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface"

# Add DVD drive with mounted ISO.
Add-VMDvdDrive -VMName $VMName -Path $IsoPath

# Set device boot order.
Set-VMFirmware -VMName $VMName -FirstBootDevice $(Get-VMDvdDrive -VMName $VMName)

# Disable secure boot for Linux virtual machines.
# https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v
if ($OperatingSystem -eq "L") {
    Set-VMFirmware -VMName $VMName -EnableSecureBoot Off
}

# Open the virtual machine console.
vmconnect.exe localhost $VMName

# Start the virtual machine.
Start-VM -VMName $VMName

# Complete the OOBE setup.

# Get the virtual machine.
Get-VM -VMName $VMName

# Stop the virtual machine gracefully.
Stop-VM -VMName $VMName

# Checkpoint the virtual machine.
Checkpoint-VM -VMName $VMName -SnapshotName "BASE"

# Stop the virtual machine forcefully.
Stop-VM -VMName $VMName -Force

# Remove the virtual machine.
Remove-VM -VMName $VMName -Force

# Remove the virtual hard disk.
Remove-Item -Path $VhdPath -Force
