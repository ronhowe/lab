#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string[]]
    $ComputerName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [PSCredential]
    $Credential,

    [int]
    $RetryInterval = 15
)
begin {
}
process {
    if ($ComputerName -is [array]) {
        $ExpectedCount = $ComputerName.Length
    }
    else {
        $ExpectedCount = 1
    }

    $ScriptBlock = {
        Start-DscConfiguration -UseExisting -Wait -ErrorAction SilentlyContinue
        return New-Object -TypeName PSObject -Property  @{ Status = (Get-DscConfigurationStatus -ErrorAction SilentlyContinue).Status }
    }

    Write-Output "Getting DSC Configuration Status"

    $Count = Invoke-Command -ComputerName $ComputerName -Credential $AdministratorCredential -ScriptBlock $ScriptBlock -ErrorAction SilentlyContinue |
    Where-Object { $_.Status -eq "Success" } |
    Group-Object -Property "Status" | Select-Object -ExpandProperty "Count"

    while ($Count -ne $ExpectedCount) {
        Write-Output "Checking again in $RetryInterval seconds..."

        Start-Sleep -Seconds $RetryInterval

        $Count = Invoke-Command -ComputerName $ComputerName -Credential $AdministratorCredential -ScriptBlock $ScriptBlock -ErrorAction SilentlyContinue |
        Where-Object { $_.Status -eq "Success" } |
        Group-Object -Property "Status" | Select-Object -ExpandProperty "Count"
    }
}
end {
}