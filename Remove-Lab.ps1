#requires -RunAsAdministrator
#requires -PSEdition Desktop

Set-Location -Path $PSScriptRoot

$ComputerNames = @("DC01", "SQL01", "USER01", "WEB01")

.\Import-HostDependencies.ps1

$ComputerNames | Stop-VM -TurnOff -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

.\Invoke-HostConfiguration.ps1 -Ensure "Absent" -Wait
