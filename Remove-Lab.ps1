#requires -RunAsAdministrator
#requires -PSEdition Desktop

Set-Location -Path $PSScriptRoot

$ComputerNames = @("DC41", "SQL41", "USER41", "WEB41")

.\Import-HostDependencies.ps1

$ComputerNames | Stop-VM -TurnOff -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

.\Invoke-HostConfiguration.ps1 -Ensure "Absent" -Wait
