# Configure preferences.
$ProgressPreference = "SilentlyContinue"

# Import modules.

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter administrator Credential" -UserName "administrator"
$Username = $Credential.Username
$ComputerName = Read-Host -Prompt "Enter Computer Name"

# Test SSH
Test-NetConnection -ComputerName $ComputerName -Port 22

# Remote witih SSH
# ssh administrator@linux-vm
ssh "$Username@$ComputerName"
