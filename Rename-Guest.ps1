#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullorEmpty()]
    [string]
    $ComputerName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]
    $Credential
)
begin {
}
process {
    foreach ($Computer in $ComputerName) {
        Write-Output "Renaming Guest $Computer"
        $ScriptBlock = {
            $ProgressPreference = "SilentlyContinue"
            Rename-Computer -NewName $using:Computer -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        Invoke-Command -VMName $Computer -Credential $Credential -ScriptBlock $ScriptBlock

        Write-Output "Rebooting Guest $Computer"
        Restart-VM -Name $Computer -Wait -Force
    }
}
end {
}