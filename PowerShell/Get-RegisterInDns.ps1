Param(
	[Parameter(Mandatory=$false)]
	$Computer = $env:COMPUTERNAME
)
$NetworkAdapterConfigurations = Get-WmiObject -ComputerName $Computer -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE"
ForEach($NetworkAdapterConfiguration in $NetworkAdapterConfigurations) {
	$NetworkAdapter = Get-WmiObject -ComputerName $Computer -Class Win32_NetworkAdapter -Filter $("Index={0} AND PhysicalAdapter=TRUE" -f $NetworkAdapterConfiguration.Index)
	If($NetworkAdapter -eq $null) {
		Continue
	}
	$Result = New-Object PsObject
	$Result | Add-Member -MemberType NoteProperty -Name 'Computer' -Value $Computer
	$Result | Add-Member -MemberType NoteProperty -Name 'Name' -Value $NetworkAdapter.NetConnectionId
	$Result | Add-Member -MemberType NoteProperty -Name 'RegisterInDNS' -Value $NetworkAdapterConfiguration.FullDNSRegistrationEnabled
	$Result
}