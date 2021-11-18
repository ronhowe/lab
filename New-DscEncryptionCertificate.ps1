#requires -RunAsAdministrator
#requires -PSEdition Core

# https://docs.microsoft.com/en-us/powershell/scripting/dsc/pull-server/securemof?view=powershell-7.2#certificate-creation

$Certificate = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp -DnsName "DscEncryptionCert" -HashAlgorithm SHA256

$Certificate | Export-PfxCertificate -FilePath "$env:TEMP\DscPrivateKey.pfx" -Password $MyConfiguration.DscEncryptionCertPfxPassword -Force

$Certificate | Export-Certificate -FilePath "$env:TEMP\DscPublicKey.cer" -Force

$Certificate | Remove-Item -Force

Import-Certificate -FilePath "$env:TEMP\DscPublicKey.cer" -CertStoreLocation "Cert:\LocalMachine\My"
