$AdministratorCredential = Get-Credential -Message "Enter Administrator Credential" -Username "Administrator"

$ComputerNames = @("DC01", "SQL01", "USER01", "WEB01")

$ComputerNames | .\Invoke-GuestConfiguration.ps1 -Credential $AdministratorCredential -Wait
