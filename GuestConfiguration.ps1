#requires -PSEdition Desktop

Configuration GuestConfiguration {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $Credential
    )
    
    Import-DscResource -ModuleName "ActiveDirectoryCSDsc"
    Import-DscResource -ModuleName "ActiveDirectoryDsc"
    Import-DscResource -ModuleName "ComputerManagementDsc"
    Import-DscResource -ModuleName "NetworkingDsc"
    Import-DscResource -ModuleName "PSDscResources"
    Import-DscResource -ModuleName "SqlServerDsc"

    #region Helpers
    function Get-NodeGatewayIpAddress {
        return Get-NetIPConfiguration -InterfaceAlias "vEthernet (Default Switch)" | Select-Object -ExpandProperty "IPv4Address" | Select-Object -ExpandProperty "IPAddress"
    }
    
    function Get-NodeIpAddress {
        param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [string]
            $NodeName,
    
            [Parameter(Mandatory = $false)]
            [int]
            $Subnet
        )
    
        $IpAddress = $(Get-NodeGatewayIpAddress).Split(".")

        $IpAddress[-1] = switch ($NodeName) {
            "DC01" {
                10
            }
            "SQL01" {
                20
            }
            "USER01" {
                40
            }
            "WEB01" {
                30
            }
        }

        if ($Subnet) {
            return "{0}/{1}" -f ($IpAddress -join "."), $Subnet
        }
        else {
            return $IpAddress -join "."
        }
    }
    #endregion Helpers

    $DomainCredential = New-Object System.Management.Automation.PSCredential ($("{0}\{1}" -f $Node.DomainName, $Credential.UserName), $Credential.Password)

    Node $AllNodes.NodeName {
        LocalConfigurationManager {
            ActionAfterReboot  = $Node.ActionAfterReboot
            CertificateId      = $Node.CertificateId
            ConfigurationMode  = $Node.ConfigurationMode
            RebootNodeIfNeeded = $Node.RebootNodeIfNeeded
        }
        File "DeleteDscEncryptionPfx" {
            DestinationPath = "C:\DscPrivateKey.pfx"
            Ensure          = "Absent"
            Type            = "File"
        }
        TimeZone "SetTimeZone" {
            IsSingleInstance = "Yes"
            TimeZone         = $Node.TimeZone
        }
        NetIPInterface "DisableDhcp" {
            AddressFamily  = "IPv4"
            Dhcp           = "Disabled"
            InterfaceAlias = "Ethernet"
        }
        IPAddress "SetIPAddress" {
            AddressFamily  = "IPV4"
            InterfaceAlias = "Ethernet"
            IPAddress      = Get-NodeIpAddress -NodeName $Node.NodeName -Subnet $Node.Subnet
        }
        DefaultGatewayAddress "SetDefaultGatewayIpAddress" {
            Address        = Get-NodeGatewayIpAddress
            AddressFamily  = "IPv4"
            InterfaceAlias = "Ethernet"
        }
        if ($Node.NodeName -eq "DC01") {
            Computer "RenameComputer" {
                Name = $Node.NodeName
            }
            DnsServerAddress "SetDnsServerIpAddress" {
                Address        = Get-NodeGatewayIpAddress
                AddressFamily  = "IPv4"
                InterfaceAlias = "Ethernet"
                Validate       = $false
            }
        }
        else {
            DnsServerAddress "SetDnsServerIpAddress" {
                Address        = Get-NodeIpAddress -NodeName "DC01"
                AddressFamily  = "IPv4"
                InterfaceAlias = "Ethernet"
                Validate       = $false
            }
            WaitForADDomain "WaitForActiveDirectory" {
                Credential   = $Credential
                DomainName   = $Node.DomainName
                RestartCount = $Node.RestartCount
                WaitTimeout  = $Node.WaitTimeout
            }
            Computer "JoinDomain" {
                Credential = $DomainCredential
                DependsOn  = "[WaitForADDomain]WaitForActiveDirectory"
                DomainName = $Node.DomainName
                Name       = $Node.NodeName
            }
        }
        RemoteDesktopAdmin "SetRemoteDesktopSettings" {
            Ensure             = "Present"
            IsSingleInstance   = "Yes"
            UserAuthentication = "NonSecure"
        }
        if ($Node.Sku -eq "Desktop") {
            Service "SetNetworkResourceDiscovery" {
                Name        = "FDResPub"
                StartupType = "Automatic"
                State       = "Running"
            }
        }
        $Node.FirewallRules | ConvertFrom-Csv | ForEach-Object {
            Firewall "SetFirewallRule$($_.Name)" {
                Action  = "Allow"
                Enabled = $true
                Ensure  = "Present"
                Name    = $_.Name
                Profile = @("Domain", "Private")
            }
        }
        Registry "EnableRemoteDesktop" {
            Ensure    = "Present"
            Key       = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server"
            ValueData = "0"
            ValueName = "fdenyTSConnections"
        }
    }
    Node "DC01" {
        WindowsFeature "InstallActiveDirectoryServices" {
            Ensure = "Present"
            Name   = "AD-Domain-Services"
        }
        if ($Node.Sku -eq "Desktop") {
            WindowsFeature "InstallActiveDirectoryTools" {
                DependsOn = "[WindowsFeature]InstallActiveDirectoryServices"
                Ensure    = "Present"
                Name      = "RSAT-ADDS"
            }
        }
        ADDomain "ConfigureActiveDirectory" {
            Credential                    = $Credential
            DatabasePath                  = $Node.DatabasePath
            DependsOn                     = "[WindowsFeature]InstallActiveDirectoryServices"
            DomainName                    = $Node.DomainName
            LogPath                       = $Node.LogPath
            SafemodeAdministratorPassword = $Credential
            SysvolPath                    = $Node.SysvolPath
        }
        PendingReboot "RebootAfterConfigureActiveDirectory" {
            DependsOn                   = "[ADDomain]ConfigureActiveDirectory"
            Name                        = "RebootAfterConfigureActiveDirectory"
            SkipCcmClientSDK            = $Node.SkipCcmClientSDK
            SkipComponentBasedServicing = $Node.SkipComponentBasedServicing
            SkipPendingFileRename       = $Node.SkipPendingFileRename
            SkipWindowsUpdate           = $Node.SkipWindowsUpdate
        }
        WaitForADDomain "WaitForActiveDirectory" {
            Credential   = $Credential
            DomainName   = $Node.DomainName
            RestartCount = $Node.RestartCount
            WaitTimeout  = $Node.WaitTimeout
        }
        ADOptionalFeature "EnableActiveDirectoryRecycleBin" {
            DependsOn                         = "[WaitForADDomain]WaitForActiveDirectory"
            EnterpriseAdministratorCredential = $Credential
            FeatureName                       = "Recycle Bin Feature"
            ForestFQDN                        = $Node.DomainName
        }
    }
    Node "SQL01" {
        SqlSetup "InstallSqlServer" {
            DependsOn            = "[Computer]JoinDomain"
            Features             = $Node.Features
            ForceReboot          = $true
            InstanceName         = $Node.InstanceName
            PsDscRunAsCredential = $Credential
            SAPwd                = $Credential
            SecurityMode         = "SQL"
            SourcePath           = $Node.SourcePath
            SQLSysAdminAccounts  = $Node.SQLSysAdminAccounts
            TcpEnabled           = $true
            UpdateEnabled        = $true
        }
        SqlWindowsFirewall "SetSqlServerFirewall" {
            DependsOn    = "[SqlSetup]InstallSqlServer"
            Ensure       = "Present"
            Features     = $Node.Features
            InstanceName = $Node.InstanceName
            SourcePath   = $Node.SourcePath
        }
    }
    Node "USER01" {
        File "CreateTestFolder" {
            DestinationPath = $Node.TestFolderPath
            Ensure          = "Present"
            Type            = "Directory"
        }
    }
    Node "WEB01" {
        WindowsFeature "InstallWebServer" {
            Ensure = "Present"
            Name   = "Web-Server" 
        }
    }
}
