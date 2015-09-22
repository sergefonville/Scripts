[Void][Reflection.Assembly]::LoadWithPartialName('System.Data')
$SQLServers = @()
$SQLServers += 'sql-resource01'
$SQLServers += 'sql-resource02'
$SQLServers += 'sql-resource03'
$SQLServers += 'sql-resource04'
$SQLServers += 'sql-resource05'


ForEach($SQLServer in $SQLServers) {
	$Query = @"
	WITH DatabaseSizes AS (
		SELECT
			size
		  , d.name
		FROM sys.master_files mf
		INNER JOIN sys.databases d
			ON mf.database_id = d.database_id
		WHERE mf.type = 0
		AND mf.database_id > 4
	)
	SELECT Name, [SizeInMB] = CAST(Size * 8 / 1024  AS DECIMAL(10,2)) FROM DatabaseSizes
"@
	$Connection = New-Object System.Data.SqlClient.SqlConnection
	$ConnectionString = "Data Source=${SQLServer};Initial Catalog=master;Integrated Security=True"
	$Connection.ConnectionString = $ConnectionString
	$Connection.Open()
	$Command = $Connection.CreateCommand()
	$Command.CommandType = [System.Data.CommandType]::Text
	$Command.CommandText = $Query
	$Reader = $Command.ExecuteReader()
	While($Reader.Read() -eq $true) {
		$Result = New-Object PSObject
		$Result | Add-Member -MemberType Noteproperty -Name 'SQLServer' -Value $SQLServer
		$Result | Add-Member -MemberType Noteproperty -Name 'Name' -Value $Reader[0]
		$Result | Add-Member -MemberType Noteproperty -Name 'SizeInMB' -Value $Reader[1]
		$Result
	}
}