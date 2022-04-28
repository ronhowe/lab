$TestCases = @(
    @{ ComputerName = "DC02" }
    @{ ComputerName = "SQL02" }
    @{ ComputerName = "USER02" }
    @{ ComputerName = "WEB02" }
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
