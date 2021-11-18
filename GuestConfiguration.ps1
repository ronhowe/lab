#requires -PSEdition Desktop

#region Online Documentation
# https://docs.microsoft.com/en-us/powershell/scripting/dsc/managing-nodes/metaConfig?view=powershell-7.2
# https://github.com/dsccommunity/ActiveDirectoryDsc/wiki
# https://github.com/dsccommunity/NetworkingDsc/wiki
# https://github.com/dsccommunity/SqlServerDsc/wiki
#endregion Online Documentation

Configuration GuestConfiguration {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $Credential
    )
    
    #region DSC Resources
    Import-DscResource -ModuleName "ActiveDirectoryCSDsc"
    Import-DscResource -ModuleName "ActiveDirectoryDsc"
    Import-DscResource -ModuleName "ComputerManagementDsc"
    Import-DscResource -ModuleName "NetworkingDsc"
    Import-DscResource -ModuleName "PSDscResources"
    Import-DscResource -ModuleName "SqlServerDsc"
    #endregion DSC Resources

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
    
    $DomainCredential = New-Object System.Management.Automation.PSCredential ($("{0}\{1}" -f $Node.DomainName, $Credential.UserName), $Credential.Password)
    #endregion Helpers

    #region All Nodes
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
    #endregion All Nodes

    #region Domain Server
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
        #region Active Directory Certificate Services
        # WindowsFeature "InstallActiveDirectoryCertificateServices" {
        #     Name      = @("AD-Certificate", "ADCS-Cert-Authority", "ADCS-Web-Enrollment", "ADCS-Enroll-Web-Pol", "ADCS-Enroll-Web-Svc", "RSAT-ADCS", "RSAT-ADCS-Mgmt")
        #     Ensure    = "Present"
        #     DependsOn = "[WaitForADDomain]WaitForActiveDirectory"
        # }
        # AdcsCertificationAuthority "ConfigureADCSCertificationAuthority" {
        #     IsSingleInstance = "Yes"
        #     Credential       = $Credential
        #     CAType           = "EnterpriseRootCA"
        #     Ensure           = "Present"
        #     DependsOn        = "[WindowsFeatureSet]InstallActiveDirectoryCertificateServices"
        # }
        # AdcsWebEnrollment "ConfigureADCSWebEnrollment" {
        #     IsSingleInstance = "Yes"
        #     Credential       = $Credential
        #     Ensure           = "Present"
        #     DependsOn        = "[AdcsCertificationAuthority]ConfigureADCSCertificationAuthority"
        # }
        #endregion Active Directory Certificate Services
    }
    #endregion Domain Server

    #region SQL Server
    Node "SQL01" {
        # https://github.com/dsccommunity/SqlServerDsc/wiki/SqlSetup
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
    #endregion SQL Server
    
    #region Web Server
    Node "WEB01" {
        WindowsFeature "InstallWebServer" {
            Ensure = "Present"
            Name   = "Web-Server" 
        }
    }
    #endregion Web Server
}
