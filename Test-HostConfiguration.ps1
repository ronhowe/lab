$TestCases = @(
    @{ ComputerName = "DC-VM" }
    @{ ComputerName = "SQL-VM" }
    @{ ComputerName = "USER-VM" }
    @{ ComputerName = "WEB-VM" }
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
