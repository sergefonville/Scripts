Param(
	[Parameter(Mandatory=$false)]
	[String]$ComputerName = 'localhost'
)
Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $ComputerName -Property Capacity | Measure-Object -Sum Capacity | Select-Object @{Name='RAM';Expression={$_.Sum / [Math]::Pow(1024,3)}}
