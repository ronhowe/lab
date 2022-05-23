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
    $AdministratorCredential,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]
    $UserCredential
)
begin {
}
process {
    foreach ($Computer in $ComputerName) {
        Write-Output "Renaming Guest $Computer"
        if ($Computer -eq "USER-VM") {
            $Credential = $UserCredential
        }
        else {
            $Credential = $AdministratorCredential
        }
        $ScriptBlock = {
            Rename-Computer -NewName $using:Computer -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
        Invoke-Command -VMName $Computer -Credential $Credential -ScriptBlock $ScriptBlock

        Write-Output "Rebooting Guest $Computer"
        Restart-VM -Name $Computer -Wait -Force
    }
}
end {
}