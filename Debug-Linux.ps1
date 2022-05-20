# Configure preferences.
$ProgressPreference = "SilentlyContinue"

# Import modules.

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter administrator Credential" -UserName "administrator"
$ComputerName = Read-Host -Prompt "Enter Computer Name"
