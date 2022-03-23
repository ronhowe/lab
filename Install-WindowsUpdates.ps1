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
    $Credential)
begin {
}
process {
    $ScriptBlock = {
        Import-Module -Name "PSWindowsUpdate"

        # Unfortunately, fails to install with "Access denied".
        # Generally a known failing of this module.
        Install-WindowsUpdate -AcceptAll -AutoReboot
    }

    Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -Credential $Credential
}
end {
}