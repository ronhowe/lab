# Overview

This repo contains PowerShell scripts for provisioning and configuring a minimal lab environment.  The lab is intended to be used for learning the Microsoft platform.  Evaluation and developer ISOs are freely downloadable directly from Microsoft.

The lab consists of the following four virtual machine nodes:

- **DC01** - Microsoft Windows Server node running Active Directory Domain Services.
- **SQL01** - Microsoft Windows Server node running SQL Server.
- **WEB01** - Microsoft Windows Server node running Internet Information Services.
- **USER01** - Microsoft Windows 10 node.

All nodes are joined to a **LAB.LOCAL** domain.

# Secrets

It is recommended that you use the same value for any secret when prompted.  This includes, but is not limited to the following:
- `New-Lab.ps1`
    - **Administrator** - This is the Administrator account for nodes running Windows Server.  When completing the Windows Server installation, use this password.
    - **User** - This is the User account for nodes running Windows 10.  When completing the Windows 10 installation, use this password.
- `New-DscEncryptionCertificate.ps1`
    - **Password** - This is the password used when creating the certificate PFX file.

# Host Requirements

These scripts were developed and tested on my home PC with the following hardware and software:

- **CPU** - Intel 5960X (16 cores)
- **RAM** - 64 GB
- **Storage** - 1 TB NVME SSD with ~200 GB free space
- **Operating System** - Microsoft Windows 10 Pro

Each guest virtual machine is provisioned with 4 CPU, 4 GB of RAM and a 50 GB disk.  This can be customized in `HostConfiguration.psd1`.

# Host Preparation

1. Download the following ISOs:

- [Microsoft Windows Server 2022](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022)
- [Microsoft Windows 10](https://www.microsoft.com/en-us/software-download/windows10)
- [Microsoft SQL Server 2019](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)

2. Enable Hyper-V in Windows.
3. Run Windows PowerShell as **Administrator**.
4. Execute the following commands:

`Import-Module -Name "Hyper-V"`

`Get-VMHost | Select-Object -ExpandProperty "VirtualHardDiskPath"`

`.\New-DscEncryptionCertificate.ps1 # prompts for password`

5. Edit `HostConfiguration.psd1`:

- `SqlServerIsoPath` - The path to the SQL Server 2019 ISO downloaded above.
- `VirtualHardDisksPath` - The path to virtual hard disks (`VirtualHardDiskPath`) from above.
- `WindowsClientIsoPath` - The path to the Windows 10 ISO downloaded above.
- `WindowsServerIsoPath` - The path to the Windows Server 2022 ISO downloaded above.

6. Edit `GuestConfiguration.psd1`:

- `Sku` - In the spirit of security, all server nodes are intended to run Microsoft Windows Server "Core".  As such, they do not have a Desktop Experience installed and need to be managed remotely from the client node via remote PowerShell, Windows Admin Center, Remote Server Administration Tools (RSAT), SQL Server Management Studio, etc.  If you wish to install Windows Server with a Desktop Expirience, change **Core** to **Desktop** accordingly.
- `Thumbprint` - From `New-DscEncryptionCertificate.ps1` above.
- `TimeZone` - [List of .NET Time Zone Values](https://lonewolfonline.net/timezone-information/#:~:text=List%20of%20.Net%20Timezone%20Values%20%20%20,%20%20False%20%2018%20more%20rows%20)


# Setup

This script will pause in order for you to complete the operating system setup wizard on each virtual machine.  For Windows 10, opt to create a local user "User" and select the Domain Join option.

`.\New-Lab.ps1`

# Testing

`.\Test-Lab.ps1`

# Clean Up

`.\Remove-Lab.ps1`
