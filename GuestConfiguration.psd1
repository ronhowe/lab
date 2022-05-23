@{
    AllNodes = @(
        @{
            ActionAfterReboot    = "ContinueConfiguration"
            PSDscAllowDomainUser = $true
            CertificateFile      = "$env:TEMP\DscPublicKey.cer"
            CertificateId        = "EAC69C0CDF518426D6342A0673EAA22C9A5D2860"
            ConfigurationMode    = "ApplyAndAutoCorrect"
            DomainName           = "LAB.LOCAL"
            NodeName             = "*"
            RebootNodeIfNeeded   = $true
            RestartCount         = 3
            Subnet               = 20
            TimeZone             = "Eastern Standard Time"
            WaitTimeout          = 300
            FirewallRules        = @"
Name
FPS-ICMP4-ERQ-In
FPS-ICMP4-ERQ-Out
NETDIS-FDPHOST-In-UDP
NETDIS-FDPHOST-Out-UDP
NETDIS-FDRESPUB-WSD-In-UDP
NETDIS-FDRESPUB-WSD-Out-UDP
NETDIS-LLMNR-In-UDP
NETDIS-LLMNR-Out-UDP
NETDIS-NB_Datagram-In-UDP
NETDIS-NB_Datagram-Out-UDP
NETDIS-NB_Name-In-UDP
NETDIS-NB_Name-Out-UDP
NETDIS-SSDPSrv-In-UDP
NETDIS-SSDPSrv-Out-UDP
NETDIS-UPnPHost-In-TCP
NETDIS-UPnPHost-Out-TCP
NETDIS-UPnP-Out-TCP
NETDIS-WSDEVNT-In-TCP
NETDIS-WSDEVNT-Out-TCP
NETDIS-WSDEVNTS-In-TCP
NETDIS-WSDEVNTS-Out-TCP
RemoteDesktop-UserMode-In-TCP
WMI-RPCSS-In-TCP
"@
        },
        @{
            DatabasePath                = "C:\Windows\NTDS"
            LogPath                     = "C:\Windows\NTDS"
            NodeName                    = "DC-VM"
            Sku                         = "Desktop"
            SkipCcmClientSDK            = $true
            SkipComponentBasedServicing = $true
            SkipPendingFileRename       = $true
            SkipWindowsUpdate           = $true
            SysvolPath                  = "C:\Windows\SYSVOL"
        };
        @{
            Features            = "SQLENGINE"
            InstanceName        = "MSSQLSERVER"
            NodeName            = "SQL-VM"
            Sku                 = "Desktop"
            SourcePath          = "E:\"
            SQLSysAdminAccounts = @("Administrators")
        };
        @{
            NodeName       = "USER-VM"
            Sku            = "Desktop"
            TestFolderPath = "C:\test"
        };
        @{
            NodeName = "WEB-VM"
            Sku      = "Desktop"
        };
    );
}