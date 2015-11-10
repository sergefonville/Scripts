Param(
	[Parameter(Mandatory=$true)]
	[String[]]$Server
  , [Parameter(Mandatory=$true)]
	[String]$VMName

)
If ((Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null ) {
    Add-PsSnapin VMware.VimAutomation.Core
}
If ( (Get-PSSnapin -Name VMware.VimAutomation.License -ErrorAction SilentlyContinue) -eq $null ) {
    Add-PsSnapin VMware.VimAutomation.License
}
If ( (Get-PSSnapin -Name VMware.DeployAutomation -ErrorAction SilentlyContinue) -eq $null ) {
    Add-PsSnapin VMware.DeployAutomation
}

Connect-VIServer -Server $Server | Out-Null
$VM = Get-VM -Name $VMName -Server $Server | Where-Object {$_.PowerState -eq 'PoweredOn'}
If($VM -eq $null) {
	Write-Error -Message $("No VM named {0} is powered on" -f  $VMName)
	Exit
}

$VMHardDisks = Get-VM -Name $VMName -Server $Server | Get-HardDisk | Select-Object Name, @{Name='Uuid';Expression={$_.ExtensionData.Backing.Uuid}}
$WinHardDisks = Get-WmiObject -Class Win32_DiskDrive -ComputerName $VMName -Property SerialNumber,DeviceId | Select-Object @{Name='Disk';Expression={$_.DeviceId -Replace '.*?([0-9]+)$','Disk $1'}},@{Name='SerialNumber';Expression={[Guid]$_.SerialNumber}}
ForEach($VMHardDisk in $VMHardDisks) {
	$WinHardDisk = $WinHardDisks | ?{$_.SerialNumber -eq $VMHardDisk.Uuid}
	$Result = New-Object PsObject
	$Result | Add-Member -MemberType NoteProperty -Name 'VMWareDisk' -Value $VMHardDisk.Name
	$Result | Add-Member -MemberType NoteProperty -Name 'WindowsDisk' -Value $WinHardDisk.Disk
	$Result | Add-Member -MemberType NoteProperty -Name 'VMWareUuid' -Value $VMHardDisk.Uuid
	$Result | Add-Member -MemberType NoteProperty -Name 'WindowsSerialNumber' -Value $WinHardDisk.SerialNumber
	$Result | Select-Object VMWareDisk,WindowsDisk
}