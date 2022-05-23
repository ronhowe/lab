#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param(
    [string[]]
    $ComputerNames = @("DC-VM", "SQL-VM", "USER-VM", "WEB-VM")
)

$AdministratorCredential = Get-Credential -Message "Enter Administrator Credential" -Username "Administrator"

$ComputerNames | ForEach-Object {
    Write-Output "Rebooting Guest $_"
    Restart-Computer -ComputerName $_ -Credential $AdministratorCredential -Force -Wait
}
