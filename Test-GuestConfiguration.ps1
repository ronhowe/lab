$TestCases = @(
    @{ ComputerName = "DC02" }
    @{ ComputerName = "SQL02" }
    @{ ComputerName = "USER02" }
    @{ ComputerName = "WEB02" }
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
        It "SQL02 SQL Port Open" {
            (Test-NetConnection -ComputerName "SQL02" -Port 1433 -WarningAction SilentlyContinue).TcpTestSucceeded | Should -BeTrue
        }
    }
}
Describe "Web Server" {
    Context "Endpoint" {
        It "WEB02 HTTP Port Open" {
            (Test-NetConnection -ComputerName "WEB02" -Port 80 -WarningAction SilentlyContinue).TcpTestSucceeded | Should -BeTrue
        }
    }
}
