Param(
	[Parameter(Mandatory=$true)]
	$Server
)
[System.Reflection.Assembly]::LoadWithPartialName("System.Data") | Out-Null
$ConnectionString = 'Data Source={0};Integrated Security=true;Initial Catalog=master' -f $Server
$SqlServer = New-Object System.Data.SqlClient.SqlConnection -ArgumentList $ConnectionString
$SqlServer.Open()
$SqlServer