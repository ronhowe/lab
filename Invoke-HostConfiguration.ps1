#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Present", "Absent")]
    [string]
    $Ensure,

    [switch]
    $Wait
)
begin {
}
process {
    Write-Output "Importing Host Configuration"
    . ".\HostConfiguration.ps1"

    Write-Output "Compiling Host Configuration"
    HostConfiguration -ConfigurationData ".\HostConfiguration.psd1" -Ensure $Ensure -OutputPath "$env:TEMP\HostConfiguration" | Out-Null

    Write-Output "Starting Host Configuration"
    Start-DscConfiguration -Path "$env:TEMP\HostConfiguration" -Force -Wait:$Wait
}
end {
}