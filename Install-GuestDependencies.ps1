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
    Write-Verbose "Getting PSSession"
    $Session = New-PSSession -ComputerName $ComputerName -Credential $Credential

    Write-Verbose "Copying PFX"
    Copy-Item -Path $PfxPath -Destination "C:\DscPrivateKey.pfx" -ToSession $Session

    Write-Verbose "Importing PFX"
    Invoke-Command -Session $Session -ScriptBlock {
        Import-PfxCertificate -FilePath "C:\DscPrivateKey.pfx" -CertStoreLocation "Cert:\LocalMachine\My" -Password $using:PfxPassword
    }

    Write-Verbose "Installing Modules"
    Invoke-Command -ComputerName $ComputerName -Credential $Credential -ScriptBlock {
        $ProgressPreference = "SilentlyContinue"
        Install-PackageProvider -Name "Nuget" -Force -Verbose | Out-Null
        Install-Module -Name "ActiveDirectoryCSDsc" -Repository "PSGallery" -Force
        Install-Module -Name "ActiveDirectoryDsc" -Repository "PSGallery" -Force
        Install-Module -Name "ComputerManagementDsc" -Repository "PSGallery" -Force
        Install-Module -Name "NetworkingDsc" -Repository "PSGallery" -Force
        Install-Module -Name "PSDscResources" -Repository "PSGallery" -Force
        Install-Module -Name "PSWindowsUpdate" -Repository "PSGallery" -Force
        Install-Module -Name "SqlServerDsc" -Repository "PSGallery" -Force
    }

    Write-Verbose "Removing PSSession"
    $Session | Remove-PSSession
}
end {
}
