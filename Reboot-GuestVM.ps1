#requires -RunAsAdministrator
#requires -PSEdition Desktop

param(
    [string[]]
    $ComputerNames = @("DC41", "SQL41", "USER41", "WEB41")
)

$ComputerNames | ForEach-Object {
    Write-Output "Rebooting Guest VM $_"
    Restart-VM -Name $_ -Wait -Force
}
