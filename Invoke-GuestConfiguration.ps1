#requires -PSEdition Desktop

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullorEmpty()]
    [string[]]
    $ComputerName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]
    $Credential,

    [switch]
    $Wait
)
begin {
    Write-Output "Importing Guest Configuration"
    . ".\GuestConfiguration.ps1"

    Write-Output "Compiling Guest Configuration"
    GuestConfiguration -ConfigurationData ".\GuestConfiguration.psd1" -OutputPath "$env:TEMP\GuestConfiguration" -Credential $Credential | Out-Null
}
process {
    foreach ($Computer in $ComputerName) {
        Write-Output "Invoking Guest Configuration on $Computer"

        Write-Output "Setting Guest Local Configuration Manager on $Computer"
        Set-DscLocalConfigurationManager -ComputerName $Computer -Credential $Credential -Path "$env:TEMP\GuestConfiguration"

        Write-Output "Starting Guest Configuration on $Computer"
        Start-DscConfiguration -ComputerName $Computer -Credential $Credential -Path "$env:TEMP\GuestConfiguration" -Force -Wait:$Wait
    }
}
end {
}