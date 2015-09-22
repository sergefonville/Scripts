Param(
	[Parameter(Mandatory=$false)]
	$Computer = $env:COMPUTERNAME
)
$Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
$RegistryKey = $Registry.OpenSubKey('System\CurrentControlSet\Control\NetworkProvider\Order')
$ProviderOrder = $RegistryKey.GetValue('ProviderOrder')
$ProviderOrder