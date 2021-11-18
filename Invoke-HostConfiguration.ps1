#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Present", "Absent")]
    [string]
    $Ensure
)

$ProgressPreference = "SilentlyContinue"

Push-Location -Path $PSScriptRoot

Write-Verbose "Importing Configuration"
. ".\HostConfiguration.ps1"

Write-Verbose "Compiling Configuration"
HostConfiguration -ConfigurationData ".\HostConfiguration.psd1" -Ensure $Ensure -OutputPath "$env:TEMP\HostConfiguration"

Write-Verbose "Starting Configuration"
Start-DscConfiguration -Path "$env:TEMP\HostConfiguration" -Force

Pop-Location
