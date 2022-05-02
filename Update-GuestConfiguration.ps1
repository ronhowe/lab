#requires -RunAsAdministrator
#requires -PSEdition Desktop

param(
    [string[]]
    $ComputerNames = @("DC41", "SQL41", "USER41", "WEB41")
)

Set-Location -Path $PSScriptRoot

$AdministratorCredential = Get-Credential -Message "Enter Administrator Credential" -Username "Administrator"

$ComputerNames | .\Invoke-GuestConfiguration.ps1 -Credential $AdministratorCredential -Wait -Verbose
