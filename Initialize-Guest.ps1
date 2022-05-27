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
            Get-NetAdapter -Name "Ethernet" | Set-NetConnectionProfile -NetworkCategory Private

            Write-Output "Enabling WinRM on $env:COMPUTERNAME"
            Start-Process -FilePath "winrm" -ArgumentList @("quickconfig", "-force")

            Write-Output "Setting Execution Policy to Unrestricted on $env:COMPUTERNAME"
            Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force

            Write-Output "Setting Static IP Configuration on $env:COMPUTERNAME"
            $IpAddress =
            switch ($env:COMPUTERNAME) {
                "DC-VM" { "192.168.0.10" }
                "SQL-VM" { "192.168.0.20" }
                "USER-VM" { "192.168.0.40" }
                "WEB-VM" { "192.168.0.30" }
                default { throw }
            }
            $InterfaceIndex = $(Get-NetAdapter -Name "Ethernet").ifIndex
            Remove-NetIPAddress -InterfaceIndex $InterfaceIndex -Confirm:$false
            Remove-NetRoute -InterfaceIndex $InterfaceIndex -Confirm:$false
            New-NetIPAddress -IPAddress $IpAddress -AddressFamily IPv4 -PrefixLength "24" -InterfaceIndex $InterfaceIndex -DefaultGateway "192.168.0.1" | Out-Null
            Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses ("192.168.1.1") | Out-Null
        }
        end {
        }
    }
    foreach ($Computer in $ComputerName) {
        Write-Output "Initializing Guest $Computer"
        if ($Computer -eq "USER-VM") {
            Invoke-Command -VMName $ComputerName -Credential $UserCredential -ScriptBlock $ScriptBlock -ArgumentList $AdministratorCredential

        }
        else {
            Invoke-Command -VMName $ComputerName -Credential $AdministratorCredential -ScriptBlock $ScriptBlock -ArgumentList $AdministratorCredential
        }
    }
}
end {
}