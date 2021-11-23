$TestCases = @(
    @{ ComputerName = "DC01" }
    @{ ComputerName = "SQL01" }
    @{ ComputerName = "USER01" }
    @{ ComputerName = "WEB01" }
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
        It "SQL01 SQL Port Open" {
            (Test-NetConnection -ComputerName "SQL01" -Port 1433 -WarningAction SilentlyContinue).TcpTestSucceeded | Should -BeTrue
        }
    }
}
Describe "Web Server" {
    Context "Endpoint" {
        It "WEB01 HTTP Port Open" {
            (Test-NetConnection -ComputerName "WEB01" -Port 80 -WarningAction SilentlyContinue).TcpTestSucceeded | Should -BeTrue
        }
    }
}
