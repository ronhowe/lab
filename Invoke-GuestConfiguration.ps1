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
    $Credential
)
begin {
    $ProgressPreference = "SilentlyContinue"

    Push-Location -Path $PSScriptRoot

    Write-Verbose "Importing Configuration"
    . ".\GuestConfiguration.ps1"

    Write-Verbose "Compiling Configuration"
    GuestConfiguration -ConfigurationData ".\GuestConfiguration.psd1" -OutputPath "$env:TEMP\GuestConfiguration" -Credential $Credential
}
process {
    foreach ($Computer in $ComputerName) {
        Write-Verbose "Setting Local Configuration Manager"
        Set-DscLocalConfigurationManager -ComputerName $Computer -Credential $Credential -Path "$env:TEMP\GuestConfiguration"

        Write-Verbose "Starting Configuration"
        Start-DscConfiguration -ComputerName $Computer -Credential $Credential -Path "$env:TEMP\GuestConfiguration" -Force
    }
}
end {
    Pop-Location
}