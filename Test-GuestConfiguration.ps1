$TestCases = @(
    @{ ComputerName = "DC41" }
    @{ ComputerName = "SQL41" }
    @{ ComputerName = "USER41" }
    @{ ComputerName = "WEB41" }
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
        It "SQL41 SQL Port Open" {
            (Test-NetConnection -ComputerName "SQL41" -Port 1433 -WarningAction SilentlyContinue).TcpTestSucceeded | Should -BeTrue
        }
    }
}
Describe "Web Server" {
    Context "Endpoint" {
        It "WEB41 HTTP Port Open" {
            (Test-NetConnection -ComputerName "WEB41" -Port 80 -WarningAction SilentlyContinue).TcpTestSucceeded | Should -BeTrue
        }
    }
}
