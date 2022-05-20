#requires -RunAsAdministrator

# Configure preferences.
$ProgressPreference = "SilentlyContinue"

# Import modules.
Import-Module -Name "Hyper-V"

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter Administrator Credential"
$VMName = Read-Host -Prompt "Enter Virtual Machine Name"
$VhdPath = "D:\Hyper-V\Virtual Hard Disks\$VMName.vhdx"
$IsoPath = "C:\Users\ronhowe\Downloads\LAB\Windows Server 2022.iso"
$SwitchName = "Default Switch"

# Create the virtual hard disk.
New-VHD -Path $VhdPath -SizeBytes 127GB -Dynamic

# Get the virtual hard disk.
Get-VHD -Path $VhdPath

# Create the virtual machine.
New-VM -Name $VMName -MemoryStartupBytes 4GB -VHDPath $VhdPath -SwitchName $SwitchName -Generation 2

# Get the virtual machine.
Get-VM -VMName $VMName

# Set the virtual machine processor count.
Set-VM -VMName $VMName -ProcessorCount 4

# Disable automatic checkpoints.
Set-VM -Name  $VMName -AutomaticCheckpointsEnabled $false

# Enable guest services.
Enable-VMIntegrationService -VMName $VMName -Name "Guest Service Interface"

# Add DVD drive with mounted ISO.
Add-VMDvdDrive -VMName $VMName -Path $IsoPath

# Set device boot order.
Set-VMFirmware -VMName $VMName -FirstBootDevice $(Get-VMDvdDrive -VMName $VMName)

# Get device boot order.
Get-VMFirmware -VMName $VMName | Select-Object -ExpandProperty "BootOrder"

# Start the virtual machine.
Start-VM -VMName $VMName

# Finish OOBE setup.

# Rename the virtual machine.
Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock { Rename-Computer -NewName $using:VMName -Restart -Force }

# Get the virtual machine name.
Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock { hostname }

# Stop the virtual machine.
Stop-VM -VMName $VMName -Force

# Remove the virtual machine.
Remove-VM -VMName $VMName -Force

# Remove the virtual hard disk.
Remove-Item -Path $VhdPath -Force