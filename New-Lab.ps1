#requires -RunAsAdministrator
#requires -PSEdition Desktop

Set-Location -Path $PSScriptRoot

$AdministratorCredential = Get-Credential -Message "Enter Administrator Credential" -UserName "Administrator"

$UserCredential = Get-Credential -Message "Enter User Credential" -UserName "User"

$ComputerNames = @("DC-VM", "SQL-VM", "USER-VM", "WEB-VM")

.\Install-HostDependencies.ps1

.\Import-HostDependencies.ps1

.\Invoke-HostConfiguration.ps1 -Ensure "Present" -Wait

$ComputerNames | Start-VM

$ComputerNames | ForEach-Object { Start-Process -FilePath "vmconnect.exe" -ArgumentList @("localhost", $_) }

Read-Host "Hit Enter after completing the operating system installation on all lab virtual machines"

# $ComputerNames | Checkpoint-VM -SnapshotName "OOBE"

$ComputerNames | .\Rename-Guest.ps1 -AdministratorCredential $AdministratorCredential -UserCredential $UserCredential

$ComputerNames | .\Initialize-Guest.ps1 -AdministratorCredential $AdministratorCredential -UserCredential $UserCredential

$ComputerNames | .\Install-GuestDependencies.ps1 -Credential $AdministratorCredential -PfxPath ".\DscPrivateKey.pfx" -PfxPassword $AdministratorCredential.Password

$ComputerNames | .\Invoke-GuestConfiguration.ps1 -Credential $AdministratorCredential

.\Wait-GuestConfiguration.ps1 -ComputerName $ComputerNames -Credential $AdministratorCredential -RetryInterval 3

.\Test-Lab.ps1
