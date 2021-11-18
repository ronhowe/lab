#region Safety Net
throw
#endregion Safety Net

#region Depencencies
Import-Module -Name "Hyper-V"
Import-Module -Name "Pester"
#endregion Depencencies

#region Helpers
Set-Location -Path "~\repos\ronhowe\lab"
$Credential = Get-Credential -Message "Enter Administrator Credential" -Username "Administrator"
$ComputerNames = @("DC01", "SQL01", "WEB01")
#endregion Helpers

#region Create VM
.\Invoke-HostConfiguration.ps1 -Ensure "Present" -Verbose
#endregion Create VM

#region Get Host DSC Status
Get-DscConfigurationStatus -ErrorAction SilentlyContinue
#endregion Get Host DSC Status

#region Start VM
$ComputerNames | Start-VM -Verbose
# Start-VM -Name "DC01" -Verbose
# Start-VM -Name "SQL01" -Verbose
# Start-VM -Name "WEB01" -Verbose
#endregion Start VM

#region Get VM
$ComputerNames | Get-VM -Verbose
# Get-VM -Name "DC01" -Verbose
# Get-VM -Name "SQL01" -Verbose
# Get-VM -Name "WEB01" -Verbose
#endregion Get VM

#region Connect VM
$ComputerNames | ForEach-Object { Start-Process -FilePath "vmconnect.exe" -ArgumentList @("localhost", $_) }
# Start-Process -FilePath "vmconnect.exe" -ArgumentList @("localhost", "DC01")
# Start-Process -FilePath "vmconnect.exe" -ArgumentList @("localhost", "SQL01")
# Start-Process -FilePath "vmconnect.exe" -ArgumentList @("localhost", "WEB01")
#endregion Connect VM

# Complete Setup (~4 Minutes)

#region Checkpoint VM
$ComputerNames | Checkpoint-VM -Verbose
# Checkpoint-VM -Name "DC01" -Verbose
# Checkpoint-VM -Name "SQL01" -Verbose
# Checkpoint-VM -Name "WEB01" -Verbose
#endregion Checkpoint VM

#region Rename Guest
$ComputerNames | .\Rename-Guest.ps1 -Credential $Credential -Verbose
# .\Rename-Guest.ps1 -ComputerName "DC01" -Credential $Credential -Verbose
# .\Rename-Guest.ps1 -ComputerName "SQL01" -Credential $Credential -Verbose
# .\Rename-Guest.ps1 -ComputerName "WEB01" -Credential $Credential -Verbose
#endregion Rename Guest

#region Install Guest Dependencies (~3.5 Minutes)
$ComputerNames | .\Install-GuestDependencies.ps1 -Credential $Credential -PfxPath "$env:TEMP\DscPrivateKey.pfx" -PfxPassword $Credential.Password -Verbose
# .\Install-GuestDependencies.ps1 -ComputerName "DC01" -Credential $Credential -PfxPath "$env:TEMP\DscPrivateKey.pfx" -PfxPassword $Credential.Password -Verbose
# .\Install-GuestDependencies.ps1 -ComputerName "SQL01" -Credential $Credential -PfxPath "$env:TEMP\DscPrivateKey.pfx" -PfxPassword $Credential.Password -Verbose
# .\Install-GuestDependencies.ps1 -ComputerName "WEB01" -Credential $Credential -PfxPath "$env:TEMP\DscPrivateKey.pfx" -PfxPassword $Credential.Password -Verbose
#endregion Install Guest Dependencies

#region Invoke Guest Configuration
$ComputerNames | .\Invoke-GuestConfiguration.ps1 -Credential $Credential -Verbose
# .\Invoke-GuestConfiguration.ps1 -ComputerName "DC01" -Credential $Credential -Verbose
# .\Invoke-GuestConfiguration.ps1 -ComputerName "SQL01" -Credential $Credential -Verbose
# .\Invoke-GuestConfiguration.ps1 -ComputerName "WEB01" -Credential $Credential -Verbose
#endregion Invoke Guest Configuration

#region Restart VM
$ComputerNames | Start-VM -Verbose
# Restart-VM -Name "DC01" -Verbose
# Restart-VM -Name "SQL01" -Verbose
# Restart-VM -Name "WEB01" -Verbose
#endregion Restart VM

#region Get Guest DSC Status
$ScriptBlock = { return New-Object -TypeName PSObject -Property  @{ Status = (Get-DscConfigurationStatus -ErrorAction SilentlyContinue).Status } }
Invoke-Command -ComputerName @("DC01", "SQL01", "WEB01") -Credential $Credential -ScriptBlock $ScriptBlock -ErrorAction SilentlyContinue |
Sort-Object -Property "PSComputerName" |
Format-Table -AutoSize
#endregion Get Guest DSC Status

#region Test Configurations
Invoke-Pester -Script .\Test-Configurations.ps1 -Output Detailed
#endregion Test Configurations

#region Stop VM
$ComputerNames | Stop-VM -ErrorAction SilentlyContinue -Verbose
# Stop-VM -Name "DC01" -ErrorAction SilentlyContinue -Verbose
# Stop-VM -Name "SQL01" -ErrorAction SilentlyContinue -Verbose
# Stop-VM -Name "WEB01" -ErrorAction SilentlyContinue -Verbose
#endregion Stop VM

#region Delete VM
.\Invoke-HostConfiguration.ps1 -Ensure "Absent" -Verbose
#endregion Delete VM
