#requires -RunAsAdministrator

Set-Item -Path "WSMan:\localhost\MaxEnvelopeSizeKb" -Value 8192
