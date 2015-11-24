[CmdletBinding()]
Param (
	[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
	[String]$SqlServer
  , [Parameter(Mandatory=$true)]
	[String]$Setting
  , [Parameter(Mandatory=$true)]
	[String]$Value
)
Begin {
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
}
Process {
	$Server = New-Object  Microsoft.SqlServer.Management.Smo.Server -ArgumentList $SqlServer
	$Server.ConnectionContext.LoginSecure = $true
	$Result = "" | Select-Object 'Server','Setting', 'ConfigValue', 'RunValue'
	$Result.Server = $SqlServer
	$Result.Setting = $Setting
	$Result.ConfigValue = $Server.Configuration.$Setting.ConfigValue
	$Result.RunValue = $Server.Configuration.$Setting.RunValue
	$Result
}
End {
	Exit
}
