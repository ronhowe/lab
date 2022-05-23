# Overview

This repo contains PowerShell scripts for provisioning and configuring a minimal lab environment.  The lab is intended to be used for learning the Microsoft platform.  Evaluation and developer ISOs are freely downloadable directly from Microsoft.

The lab consists of the following four virtual machine nodes:

- **DC-VM** - Microsoft Windows Server node running Active Directory Domain Services.
- **SQL-VM** - Microsoft Windows Server node running SQL Server.
- **WEB-VM** - Microsoft Windows Server node running Internet Information Services.
- **USER-VM** - Microsoft Windows 10 node.

All nodes are joined to a **LAB.LOCAL** domain.  This can be customized in `GuestConfiguration.psd1`.

# Secrets

It is recommended that you use the same password value for any secret when prompted.  This includes, but is not limited to the following:
- `New-Lab.ps1`
    - **Administrator** - This is the Administrator account for nodes running Windows Server.  When completing the Windows Server installation, use this password.
    - **User** - This is the User account for nodes running Windows 10.  When completing the operating system setup wizard, use this password.
- `New-DscEncryptionCertificate.ps1`
    - **Password** - This is the password used when creating the certificate PFX file.

# Host Requirements

These scripts were developed and tested on my home PC with the following hardware and software:

- **CPU** - Intel 5960X (16 cores)
- **RAM** - 64 GB
- **Storage** - 1 TB NVME SSD with ~200 GB free space
- **Operating System** - Microsoft Windows 10 Pro 21H2

Each guest virtual machine is provisioned with **4 CPU**, **4 GB of RAM** and a **50 GB disk**.  This can be customized in `HostConfiguration.psd1`.

# Host Preparation

1. Download the following free ISOs from Microsoft:

- [Microsoft Windows Server 2022](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022)
- [Microsoft Windows 10](https://www.microsoft.com/en-us/software-download/windows10)
- [Microsoft SQL Server 2019](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)

2. Enable Hyper-V in Windows.
3. Run Windows PowerShell as **Administrator**.
4. Execute the following command(s):

`Import-Module -Name "Hyper-V"`

`Get-VMHost | Select-Object -ExpandProperty "VirtualHardDiskPath"`

5. Edit `HostConfiguration.psd1`:

- `SqlServerIsoPath` - The path to the SQL Server 2019 ISO downloaded above.
- `VirtualHardDisksPath` - The path to virtual hard disks (`VirtualHardDiskPath`) from above.
- `WindowsClientIsoPath` - The path to the Windows 10 ISO downloaded above.
- `WindowsServerIsoPath` - The path to the Windows Server 2022 ISO downloaded above.

6. Execute the following command(s):

`.\New-DscEncryptionCertificate.ps1`

7. Edit `GuestConfiguration.psd1`:

- `Sku` - In the spirit of security, all server nodes are intended to run Microsoft Windows Server "Core".  As such, they do not have a Desktop Experience installed and need to be managed remotely from the client node via remote PowerShell, Windows Admin Center, Remote Server Administration Tools (RSAT), SQL Server Management Studio, etc.  If you wish to install Windows Server with a Desktop Expirience, change **Core** to **Desktop** accordingly.
- `Thumbprint` - The thumbprint returned from `New-DscEncryptionCertificate.ps1` above.
- `TimeZone` - [List of .NET Time Zone Values](https://lonewolfonline.net/timezone-information/#:~:text=List%20of%20.Net%20Timezone%20Values%20%20%20,%20%20False%20%2018%20more%20rows%20)


# Setup

The setup script will pause in order for you to complete the operating system setup wizard on each virtual machine.  Use the following options for setting up Windows:

- **Windows Server**
    - Select either Standard Edition or Datacenter Edition
    - Select Desktop Experience only if you have customzed `GuestConfiguration.psd1` and set the `Sku` to match.
- **Windows 10**
    - Select Windows 10 Pro
    - When prompted, select these options?
        - *How would you like to set up?* - Set up for an organization
        - *Sign in with Microsoft* - Domain join instead (lower left corner)
        - *Who's going to use this PC?* - User

1. Run Windows PowerShell as **Administrator**.
2. Execute the following command(s):

`.\New-Lab.ps1`

# Testing

1. Run Windows PowerShell as **Administrator**.
2. Execute the following command(s):

`.\Test-Lab.ps1`

# Clean Up

1. Run Windows PowerShell as **Administrator**.
2. Execute the following command(s):

`.\Remove-Lab.ps1`
