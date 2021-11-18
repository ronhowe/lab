#requires -PSEdition Desktop

Configuration HostConfiguration {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Present", "Absent")]
        [string]
        $Ensure
    )
    #region DSC Resources
    Import-DscResource -ModuleName "PSDscResources"
    Import-DscResource -ModuleName "xHyper-V"
    #endregion DSC Resources

    Node "localhost" {
        #region All Nodes
        @("DC01", "SQL01", "WEB01") | ForEach-Object {
            xVHD "xVHD$_" {
                Ensure           = $Ensure
                Generation       = "VHDX"
                MaximumSizeBytes = $Node.MaximumSizeBytes
                Name             = $_
                Path             = $Node.VirtualHardDisksPath
            }
            xVMHyperV "xVMHyperV$_" {
                AutomaticCheckpointsEnabled = $false
                DependsOn                   = "[xVHD]xVHD$_"
                EnableGuestService          = $true
                Ensure                      = $Ensure
                MinimumMemory               = $Node.MinimumMemory
                Name                        = $_
                ProcessorCount              = $Node.ProcessorCount
                RestartIfNeeded             = $true
                SwitchName                  = "Default Switch"
                VhdPath                     = Join-Path -Path $Node.VirtualHardDisksPath -ChildPath "$_.vhdx"
            }
            if ($Ensure -eq "Present") {
                xVMDvdDrive "xVMDvdDriveWindows$_" {
                    ControllerLocation = 0
                    ControllerNumber   = 1
                    DependsOn          = "[xVMHyperV]xVMHyperV$_"
                    Ensure             = $Ensure
                    Path               = $Node.WindowsServerIsoPath
                    VMName             = $_
                }
                if ($_ -eq "SQL01") {
                    xVMDvdDrive "xVMDvdDriveSqlServer$_" {
                        ControllerLocation = 1
                        ControllerNumber   = 1
                        DependsOn          = "[xVMHyperV]xVMHyperV$_"
                        Ensure             = $Ensure
                        Path               = $Node.SqlServerIsoPath
                        VMName             = $_
                    }
                }
            }
        }
        #endregion All Nodes
    }
}