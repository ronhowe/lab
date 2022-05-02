$TestCases = @(
    @{ ComputerName = "DC41" }
    @{ ComputerName = "SQL41" }
    @{ ComputerName = "USER41" }
    @{ ComputerName = "WEB41" }
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
