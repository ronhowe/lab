#requires -RunAsAdministrator
#requires -PSEdition Desktop

Set-Location -Path $PSScriptRoot

$ComputerNames = @("DC-VM", "SQL-VM", "USER-VM", "WEB-VM")

.\Import-HostDependencies.ps1

$ComputerNames | Stop-VM -TurnOff -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

.\Invoke-HostConfiguration.ps1 -Ensure "Absent" -Wait
