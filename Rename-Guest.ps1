[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullorEmpty()]
    [string]
    $VMName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]
    $Credential
)
begin {
}
process {
    Write-Verbose "Renaming Computer"
    Invoke-Command -VMName $VMName -Credential $Credential -ScriptBlock { Rename-Computer -NewName $using:VMName }

    Write-Verbose "Rebooting Computer"
    Restart-VM -Name $VMName -Wait -Force
}
end {
}