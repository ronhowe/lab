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

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [string]
    $PfxPath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [securestring]
    $PfxPassword
)
begin {
}
process {
    foreach ($Computer in $ComputerName) {
        Write-Output "Installing Guest Dependencies on $Computer"

        Write-Output "Getting PSSession to $Computer"
        $Session = New-PSSession -ComputerName $Computer -Credential $Credential

        Write-Output "Copying PFX to $Computer"
        Copy-Item -Path $PfxPath -Destination "C:\DscPrivateKey.pfx" -ToSession $Session

        Write-Output "Importing PFX on $Computer"
        Invoke-Command -Session $Session -ScriptBlock {
            $ProgressPreference = "SilentlyContinue"
            Import-PfxCertificate -FilePath "C:\DscPrivateKey.pfx" -CertStoreLocation "Cert:\LocalMachine\My" -Password $using:PfxPassword | Out-Null
        }

        Write-Output "Installing Package Providers on $Computer"
        Invoke-Command -Session $Session -ScriptBlock {
            $ProgressPreference = "SilentlyContinue"
            $PackageProviders = @(
                "Nuget"
            )
            foreach ($PackageProvider in $PackageProviders) {
                Write-Output "Installing Package Provider $PackageProvider"
                Install-PackageProvider -Name $PackageProvider -Force | Out-Null
            }
        }

        Write-Output "Installing Modules on $Computer"
        Invoke-Command -Session $Session -ScriptBlock {
            $ProgressPreference = "SilentlyContinue"
            $Modules = @(
                "ActiveDirectoryCSDsc",
                "ActiveDirectoryDsc",
                "ComputerManagementDsc",
                "NetworkingDsc",
                "PSDscResources",
                "PSWindowsUpdate",
                "SqlServerDsc"
            )
            foreach ($Module in $Modules) {
                Write-Output "Installing Module $Module"
                Install-Module -Name $Module -Scope AllUsers -Repository "PSGallery" -Force
            }
        }

        Write-Output "Removing PSSession to $Computer"
        $Session | Remove-PSSession
    }
}
end {
}
