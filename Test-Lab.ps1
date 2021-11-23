#requires -RunAsAdministrator
#requires -PSEdition Desktop

$ProgressPreference = "SilentlyContinue"

Set-Location -Path $PSScriptRoot

Invoke-Pester -Script .\Test-HostConfiguration.ps1 -Output Detailed

Invoke-Pester -Script .\Test-GuestConfiguration.ps1 -Output Detailed
