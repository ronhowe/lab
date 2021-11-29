# Overview

This repo contains PowerShell scripts for provisioning and configuring a minimal lab environment.  The lab is intended to be used for learning the Microsoft platform.  Evaluation and developer ISOs are freely downloadable directly from Microsoft.

The lab consists of the following virtual machines:

- DC01 - Microsoft Windows Server server node running Active Directory Domain Services.
- SQL01 - Microsoft Windows Server server node running SQL Server.
- WEB01 - Microsoft Windows Server server node running Internet Information Services.
- USER01 - Microsoft Windows 10 client node.

All nodes are joined to a LAB.LOCAL domain.

# Host Requirements

These scripts were developed and tested on my home PC with the following hardware and software:

- CPU - Intel 5960X with 16 cores
- RAM - 64 GB of RAM
- Storage - 1 TB NVME SSD
- OS - Microsoft Windows 10 Pro

# Host Preparation

1. Download the following ISOs:

- [Microsoft Windows Server 2022](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022)
- [Microsoft Windows 10](https://www.microsoft.com/en-us/software-download/windows10)
- [Microsoft SQL Server 2019](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)

2. Enable Hyper-V in Windows.
3. Clone the repo locally.
4. Run Windows PowerShell as **Administrator**.
5. Execute the following commands:

`Import-Module -Name "Hyper-V"`

`Get-VMHost | Select-Object -ExpandProperty "VirtualHardDiskPath"`

`Install-HostDependencies.ps1 -Verbose`

`New-DscEncryptionCertificate.ps1 # prompts for password`

6. Edit **HostConfiguration.psd1**:

- `WindowsServerIsoPath` - The path to the Windows Server 2022 ISO downloaded above.
- `WindowsClientIsoPath` - The path to the Windows 10 ISO downloaded above.
- `SqlServerIsoPath` - The path to the SQL Server 2019 ISO downloaded above.
- `VirtualHardDisksPath` - The path to virtual hard disks (`VirtualHardDiskPath`) from above.

7. Edit **GuestConfiguration.psd1**:

- `Thumbprint` - From `New-DscEncryptionCertificate.ps1` above.
- `TimeZone` - [List of .NET Time Zone Values](https://lonewolfonline.net/timezone-information/#:~:text=List%20of%20.Net%20Timezone%20Values%20%20%20,%20%20False%20%2018%20more%20rows%20)
- `Sku` - In the spirit of security, all server nodes are intended to run Microsoft Windows Server "Core".  As such, they do not have a Desktop Experience installed and need to be managed remotely from the client node via remote PowerShell, Windows Admin Center, Remote Server Administration Tools (RSAT), SQL Server Management Studio, etc.  If you wish to install Windows Server with a Desktop Expirience, change **Core** to **Desktop** accordingly.


# Setup

`.\New-Lab.ps1`

Notes:
- For simplicity, the same credential (username/password) will be used for all user secrets.
- For Windows 10, use a local user "User" to complete the installation.  Use the same password used when prompted for the User credential.

# Testing

`.\Test-Lab.ps1`

# Clean Up

`.\Remove-Lab.ps1`
