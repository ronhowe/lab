#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param()
begin {
}
process {
    $Modules = @(
        "ActiveDirectoryCSDsc",
        "ActiveDirectoryDsc",
        "ComputerManagementDsc",
        "NetworkingDsc",
        "Pester",
        "PSDscResources",
        "SqlServerDsc",
        "xHyper-V"
    )
    foreach ($Module in $Modules) {
        Write-Output "Installing Module $Module"
        Install-Module -Name $Module -Scope AllUsers -Repository "PSGallery" -Force -WarningAction SilentlyContinue
    }
}
end {
}