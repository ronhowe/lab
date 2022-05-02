#requires -PSEdition Desktop

Configuration HostConfiguration {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("Present", "Absent")]
        [string]
        $Ensure
    )

    Import-DscResource -ModuleName "PSDscResources"
    Import-DscResource -ModuleName "xHyper-V"

    Node "localhost" {
        @("DC41", "SQL41", "USER41", "WEB41") | ForEach-Object {
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
                if ($_ -eq "USER41") {
                    $WindowsIsoPath = $Node.WindowsClientIsoPath
                }
                else {
                    $WindowsIsoPath = $Node.WindowsServerIsoPath
                }
                xVMDvdDrive "xVMDvdDriveWindows$_" {
                    ControllerLocation = 0
                    ControllerNumber   = 1
                    DependsOn          = "[xVMHyperV]xVMHyperV$_"
                    Ensure             = $Ensure
                    Path               = $WindowsIsoPath
                    VMName             = $_
                }
                if ($_ -eq "SQL41") {
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
    }
}