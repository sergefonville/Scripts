Param (
	[String]$Server
  , [Switch]$SkipSystem
  , [Switch]$SkipStatistics
  , [Switch]$SkipIndexes
  , [String]$DB = $null
)
$StartDirectory = Get-Location
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
$EnterpriseEdtion = [Microsoft.SqlServer.Management.Smo.Edition]::EnterpriseOrDeveloper
If($SkipSystem -and $SkipStatistics -And $SkipIndexes) {
	"Nothing to do"
	Exit
}
Write-Progress -Id 0 -Activity 'Databases' -Status 'Starting' -PercentComplete 0
$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server -ArgumentList $Server
$Instance = $Server
If($SqlServer -eq $null) {
	"{0} is not a valid instance of SQL Server" -f $Server
	Exit
}
If($SqlServer.VersionMajor -lt 10) {
	"{0} is older than SQL Server 2008" -f $Instance
	Exit
}
If($SqlServer.EngineEdition -ne $EnterpriseEdtion) {
	"Enabling index compression requires Enterprise or Developer Edition, {0} is {1}" -f $Instance, $SqlServer.Edition
	Exit
}
$All = [Microsoft.SqlServer.Management.Smo.StatisticsTarget]::All
$FullScan = [Microsoft.SqlServer.Management.Smo.StatisticsScanType]::FullScan
$DatabaseNumber = 0
ForEach($Database in $SqlServer.Databases) {
	If(($DB -ne $null) -and ($DB -ne $Database.Name)) {
		Continue
	}
	Write-Progress -Id 0 -Activity 'Databases' -Status $Database.Name -PercentComplete $($DatabaseNumber / $SqlServer.Databases.Count * 100)
	$TableNumber = 0
	ForEach($Table in $Database.Tables) {
		Write-Progress -Id 1 -Activity 'Tables' -Status $Table.Name -PercentComplete $($TableNumber / $Database.Tables.Count * 100)
		If(@('master','msdb','tempdb','model') -Contains $Database.Name) {
			Continue
		}
		$IndexNumber = 0
		If(-Not $SkipIndexes) {
			ForEach($Index in $Table.Indexes) {
			Write-Progress -Id 2 -Activity 'Indexes' -Status $index.Name -PercentComplete $($IndexNumber / $Table.Indexes.Count * 100)
				If($Index.IsDisabled -eq $true) {
					"Skipped {0}.{1}.{2}.{3} because it is disabled" -f $SqlServer, $Database, $Table, $Index
					Continue
				}
				If(-Not $Index.IsXmlIndex -eq $true) {
					ForEach($PhysicalPartition in $Index.PhysicalPartitions) {
						$PhysicalPartition.DataCompression = [Microsoft.SqlServer.Management.Smo.DataCompressionType]::Page
					}
				}
				Else {
					"Without data compression because {0}.{1}.{2}.{3} is an XML index" -f $SqlServer, $Database, $Table, $Index
				}
				$Index.OnlineIndexOperation = $true;
				Try {
					$Index.SortInTempdb = $true
					$Index.Rebuild()
					"Rebuilt {0}.{1}.{2}.{3}" -f $SqlServer, $Database, $Table, $Index
				}
				Catch {
					"Skipping {0}.{1}.{2}.{3} because an error was thrown" -f $SqlServer, $Database, $Table, $Index
				}
				$IndexNumber++
			}
		}
		If(-Not $SkipStatistics) {
			$Table.updatestatistics($All, $FullScan)
		}
		$TableNumber++
	}
	$DatabaseNumber++
}
Set-Location $StartDirectory