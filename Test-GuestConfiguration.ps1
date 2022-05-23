$TestCases = @(
    @{ ComputerName = "DC-VM" }
    @{ ComputerName = "SQL-VM" }
    @{ ComputerName = "USER-VM" }
    @{ ComputerName = "WEB-VM" }
)
Describe "Networking" {
    Context "Firewall" {
        It "<ComputerName> Can Be Pinged" -TestCases $TestCases {
            param (
                [string]
                $ComputerName
            )
            (Test-NetConnection -ComputerName $ComputerName -WarningAction SilentlyContinue).PingSucceeded | Should -BeTrue
        }
    }
}
Describe "SQL Server" {
    Context "Endpoint" {
        It "SQL-VM SQL Port Open" {
            (Test-NetConnection -ComputerName "SQL-VM" -Port 1433 -WarningAction SilentlyContinue).TcpTestSucceeded | Should -BeTrue
        }
    }
}
Describe "Web Server" {
    Context "Endpoint" {
        It "WEB-VM HTTP Port Open" {
            (Test-NetConnection -ComputerName "WEB-VM" -Port 80 -WarningAction SilentlyContinue).TcpTestSucceeded | Should -BeTrue
        }
    }
}
