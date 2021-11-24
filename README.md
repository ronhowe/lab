# Overview

Creates a domain controller, database server, web server and client machine.

All domain joined via PowerShell Desired State Configuration.

Why Core or Desktop

Can be used for learning.

Evalutation and developer ISOs are freely downloadable directly from Microsoft.

Must be Windows 10 Pro

# Requirements

Tested on an Intel 5960X with 16 cores, 64 GB of RAM and 1 TB NVME SSD running Microsoft Windows 10 Pro.

# Host Preparation

Download Microsoft ISO and note the location

- https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022
- https://www.microsoft.com/en-us/software-download/windows10
- https://www.microsoft.com/en-us/sql-server/sql-server-downloads

#region Online Documentation
# https://docs.microsoft.com/en-us/powershell/scripting/dsc/managing-nodes/metaConfig?view=powershell-7.2
# https://github.com/dsccommunity/ActiveDirectoryDsc/wiki
# https://github.com/dsccommunity/NetworkingDsc/wiki
# https://github.com/dsccommunity/SqlServerDsc/wiki
#endregion Online Documentation
        # https://github.com/dsccommunity/SqlServerDsc/wiki/SqlSetup



- Enable Hyper-V in Windows
- Run Windows PowerShell as Administrator

Install-HostDependencies.ps1 -Verbose

Import-Module -Name "Hyper-V"

Get-VMHost | Select-Object -ExpandProperty "VirtualHardDiskPath"

Update HostConfiguration.psd1 and update 

    SqlServerIsoPath     = "C:\Users\ronhowe\Downloads\LAB\SQL Server 2019 Developer.iso"
    VirtualHardDisksPath = "D:\Hyper-V\Virtual Hard Disks"
    WindowsClientIsoPath = "C:\Users\ronhowe\Downloads\LAB\Windows 10 21H2.iso"
    WindowsServerIsoPath = "C:\Users\ronhowe\Downloads\LAB\Windows Server 2022.iso"

New-DscEncryptionCertificate.ps1 -Verbose # prompts for password

Edit GuestConfiguration.psd1 and update

    Thumbprint
    Timezone
    Core or Desktop

# Guest Preparation

Organization, Domain Join, "setup" user with same, standard password

Windows PowerShell
    Install DSC Resources
    Edit host configuration
        ISO location
        Core or Desktop
    Run Debug-TestConfiguration chunks
        list them 1 by one with screenshots
        Administrator is same for all
        
    Deploy
        Install Core or Desktop
        Use same Administrator password

    Edit guest configuration
Tear down and/or checkpoint apply scenarios

# Testing

# Cleaning Up

# Resources

- https://docs.microsoft.com/en-us/powershell/scripting/dsc/pull-server/securemof?view=powershell-7.2#certificate-creation
- https://github.com/pester/Pester
- https://blog.danskingdom.com/A-better-way-to-do-TestCases-when-unit-testing-with-Pester/
- https://sqldbawithabeard.com/2017/07/06/writing-dynamic-and-random-tests-cases-for-pester/
