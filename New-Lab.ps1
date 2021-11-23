#requires -RunAsAdministrator
#requires -PSEdition Desktop

$ProgressPreference = "SilentlyContinue"

Set-Location -Path $PSScriptRoot

$AdministratorCredential = Get-Credential -Message "Enter Administrator Credential" -Username "Administrator"

$UserCredential = Get-Credential -Message "Enter User Credential" -UserName "User"

$ComputerNames = @("DC01", "SQL01", "USER01", "WEB01")

.\Install-HostDependencies.ps1

.\Import-HostDependencies.ps1

.\Invoke-HostConfiguration.ps1 -Ensure "Present" -Wait

$ComputerNames | Start-VM

$ComputerNames | ForEach-Object { Start-Process -FilePath "vmconnect.exe" -ArgumentList @("localhost", $_) }

Read-Host "Hit Enter after completing the operating system installation on all lab virtual machines"

$ComputerNames | Checkpoint-VM -SnapshotName "OOBE"

.\Initialize-Guest.ps1 -ComputerName "USER01" -AdministratorCredential $AdministratorCredential -UserCredential $UserCredential

$ComputerNames | .\Rename-Guest.ps1 -Credential $AdministratorCredential

$ComputerNames | .\Install-GuestDependencies.ps1 -Credential $AdministratorCredential -PfxPath "$env:TEMP\DscPrivateKey.pfx" -PfxPassword $AdministratorCredential.Password

$ComputerNames | .\Invoke-GuestConfiguration.ps1 -Credential $AdministratorCredential -Wait
