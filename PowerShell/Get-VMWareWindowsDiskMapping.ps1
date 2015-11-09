Param(
	[Parameter(Mandatory=$true)]
	[String[]]$Server
  , [Parameter(Mandatory=$true)]
	[String]$VM
)

$VMHardDisks = Get-VM -Name $VM -Server $Server | Get-HardDisk | Select-Object Name, @{Name='Uuid';Expression={$_.ExtensionData.Backing.Uuid}}
$WinHardDisks = Get-WmiObject -Class Win32_DiskDrive -ComputerName $VM -Property SerialNumber,DeviceId | Select-Object @{Name='Disk';Expression={$_.DeviceId -Replace '.*?([0-9]+)$','Disk $1'}},@{Name='SerialNumber';Expression={[Guid]$_.SerialNumber}}
ForEach($VMHardDisk in $VMHardDisks) {
	$WinHardDisk = $WinHardDisks | ?{$_.SerialNumber -eq $VMHardDisk.Uuid}
	$Result = New-Object PsObject
	$Result | Add-Member -MemberType NoteProperty -Name 'VMWareDisk' -Value $VMHardDisk.Name
	$Result | Add-Member -MemberType NoteProperty -Name 'WindowsDisk' -Value $WinHardDisk.Disk
	$Result | Add-Member -MemberType NoteProperty -Name 'VMWareUuid' -Value $VMHardDisk.Uuid
	$Result | Add-Member -MemberType NoteProperty -Name 'WindowsSerialNumber' -Value $WinHardDisk.SerialNumber
	$Result | Select-Object VMWareDisk,WindowsDisk
}