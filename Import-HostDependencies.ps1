#requires -RunAsAdministrator
#requires -PSEdition Desktop

[CmdletBinding()]
param()
begin {
}
process {
    $Modules = @(
        "Hyper-V",
        "Pester"
    )
    foreach ($Module in $Modules) {
        Write-Output "Importing Module $Module"
        Import-Module -Name $Module
    }
}
end {
}