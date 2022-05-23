#requires -RunAsAdministrator
#requires -PSEdition Desktop

param(
    [string[]]
    $ComputerNames = @("DC-VM", "SQL-VM", "USER-VM", "WEB-VM")
)

Set-Location -Path $PSScriptRoot

$AdministratorCredential = Get-Credential -Message "Enter Administrator Credential" -Username "Administrator"

$ComputerNames | .\Invoke-GuestConfiguration.ps1 -Credential $AdministratorCredential -Wait -Verbose
