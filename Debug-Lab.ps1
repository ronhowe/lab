$AdministratorCredential = Get-Credential -Message "Enter Administrator Credential" -Username "Administrator"

$ComputerNames = @("DC41", "SQL41", "USER41", "WEB41")

$ComputerNames | .\Invoke-GuestConfiguration.ps1 -Credential $AdministratorCredential -Wait
