#requires -RunAsAdministrator
#requires -PSEdition Desktop

Set-Item -Path "WSMan:\localhost\MaxEnvelopeSizeKb" -Value 8192
