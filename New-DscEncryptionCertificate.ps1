#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullorEmpty()]
    [securestring]
    $Password
)

Write-Verbose "Creating Self-Signed Certificate"
$Certificate = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName "DscEncryptionCert" -HashAlgorithm SHA256

Write-Verbose "Creating Self-Signed Certificate"
$Certificate | Export-PfxCertificate -FilePath ".\DscPrivateKey.pfx" -Password $Password -Force

Write-Verbose "Creating Self-Signed Certificate"
$Certificate | Export-Certificate -FilePath ".\DscPublicKey.cer" -Force

Write-Verbose "Creating Self-Signed Certificate"
$Certificate | Remove-Item -Force

Write-Verbose "Creating Self-Signed Certificate"
Import-Certificate -FilePath ".\DscPublicKey.cer" -CertStoreLocation "Cert:\LocalMachine\My"
