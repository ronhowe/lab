#requires -RunAsAdministrator
#requires -PSEdition Desktop

param(
    [string[]]
    $ComputerNames = @("DC-VM", "SQL-VM", "USER-VM", "WEB-VM")
)

$ComputerNames | ForEach-Object {
    Write-Output "Rebooting Guest VM $_"
    Restart-VM -Name $_ -Wait -Force
}
