# Configure preferences.
$ProgressPreference = "SilentlyContinue"

# Import modules.

# Set frequently used variables.
$Credential = Get-Credential -Message "Enter administrator Credential" -UserName "administrator"
$ComputerName = Read-Host -Prompt "Enter Computer Name"

# https://pitstop.manageengine.com/portal/en/kb/articles/how-to-get-the-ip-address-for-hyper-v-linux-vm-in-apm
# sudo apt-get install linux-azure

# ssh administrator@linux-vm
ssh "$($($Credential).Username)@$($ComputerName)"
