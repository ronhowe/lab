#requires -RunAsAdministrator
#requires -PSEdition Desktop

Set-Location -Path $PSScriptRoot

$ComputerNames = @("DC02", "SQL02", "USER02", "WEB02")

.\Import-HostDependencies.ps1

$ComputerNames | Stop-VM -TurnOff -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

.\Invoke-HostConfiguration.ps1 -Ensure "Absent" -Wait
