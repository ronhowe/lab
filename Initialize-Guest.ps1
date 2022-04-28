#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateNotNullorEmpty()]
    [string[]]
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
    $ScriptBlock = {
        [CmdletBinding()]
        param(
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $AdministratorCredential
        )
        begin {
        }
        process {
            Write-Output "Enabling Administrator Account on $env:COMPUTERNAME"
            Enable-LocalUser -Name "Administrator"

            Write-Output "Setting Administrator Account Password on $env:COMPUTERNAME"
            Set-LocalUser -Name "Administrator" -Password $AdministratorCredential.Password

            Write-Output "Setting Network Profile to Private on $env:COMPUTERNAME"
            Get-NetAdapter -InterfaceDescription "Microsoft Hyper-V Network Adapter" | Set-NetConnectionProfile -NetworkCategory Private

            Write-Output "Enabling WinRM on $env:COMPUTERNAME"
            Start-Process -FilePath "winrm" -ArgumentList @("quickconfig", "-force")

            Write-Output "Setting Execution Policy to Unrestricted on $env:COMPUTERNAME"
            Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
        }
        end {
        }
    }
    foreach ($Computer in $ComputerName) {
        Write-Output "Initializing Guest $Computer"
        if ($Computer -eq "USER02") {
            Invoke-Command -VMName $ComputerName -Credential $UserCredential -ScriptBlock $ScriptBlock -ArgumentList $AdministratorCredential

        }
        else {
            Invoke-Command -VMName $ComputerName -Credential $AdministratorCredential -ScriptBlock $ScriptBlock -ArgumentList $AdministratorCredential
        }
    }
}
end {
}