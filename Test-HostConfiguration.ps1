$TestCases = @(
    @{ ComputerName = "DC01" }
    @{ ComputerName = "SQL01" }
    @{ ComputerName = "USER01" }
    @{ ComputerName = "WEB01" }
)
Describe "Hyper-V" {
    Context "VM State" {
        It "<ComputerName> Is Running" -TestCases $TestCases {
            param (
                [string]
                $ComputerName
            )
            (Get-VM -Name $ComputerName).State | Should -Be "Running"
        }
    }
}
