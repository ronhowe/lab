#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
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
    Write-Output "Initializing Guest $ComputerName"
}
process {
    $ScriptBlock = {
        [CmdletBinding()]
        param(
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $AdministratorCredential
        )
        begin {}
        process {
            $ProgressPreference = "SilentlyContinue"

            Write-Output "Enabling Administrator Account"
            Enable-LocalUser -Name "Administrator"

            Write-Output "Setting Administrator Account Passowrd"
            Set-LocalUser -Name "Administrator" -Password $AdministratorCredential.Password

            Write-Output "Setting Network Profile to Private"
            Get-NetAdapter -InterfaceDescription "Microsoft Hyper-V Network Adapter" | Set-NetConnectionProfile -NetworkCategory Private

            Write-Output "Enabling WinRM"
            Start-Process -FilePath "winrm" -ArgumentList @("quickconfig", "-force")

            Write-Output "Setting Execution Policy to Unrestricted"
            Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
        }
        end {}
    }
    Invoke-Command -VMName $ComputerName -Credential $UserCredential -ScriptBlock $ScriptBlock -ArgumentList $AdministratorCredential
}
end {
}