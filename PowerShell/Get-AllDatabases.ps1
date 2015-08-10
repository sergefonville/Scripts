[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
$Instances = @()
$Instances += 'sql-resource01'
$Instances += 'sql-resource02'
$Instances += 'sql-resource03'
$Instances += 'sql-resource04'
$Instances += 'sql-resource05'

ForEach($Instance in $Instances) {
	$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server -ArgumentList $Instance
	ForEach($Database in $SqlServer.Databases) {
		If($Database.Name -in 'master','msdb','model','tempdb','dummy','DBA') {
			Continue
		}
		$Result = New-Object PsObject
		$Result | Add-Member -MemberType NoteProperty -Name 'Server' -Value $SqlServer.Name
		$Result | Add-Member -MemberType NoteProperty -Name 'Database' -Value $Database.Name
		$Result
	}
}