Param (
	[String]$Server
  , [Switch]$SkipSystem
  , [Switch]$SkipUser
  , [Switch]$SkipStatistics
  , [Switch]$SkipIndexes
  , [String]$DB = $null
)
$StartDirectory = Get-Location
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
$EnterpriseEdtion = [Microsoft.SqlServer.Management.Smo.Edition]::EnterpriseOrDeveloper
If($SkipSystem -and $SkipStatistics -And $SkipIndexes -And $SkipUser) {
	"Nothing to do"
	Exit
}
Write-Progress -Id 0 -Activity 'Databases' -Status 'Starting' -PercentComplete 0
$SqlServer = New-Object Microsoft.SqlServer.Management.Smo.Server -ArgumentList $Server
$Instance = $Server
If($SqlServer.VersionMajor -lt 10) {
	"{0} is older than SQL Server 2008" -f $Instance
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
		If(@('master','msdb','tempdb','model') -Contains $Database.Name -and $SkipSystem) {
			Continue
		}
		Else If(@('master','msdb','tempdb','model') -NotContains $Database.Name -And $SkipUser) {
			Continue
		}
		If(-Not $SkipIndexes) {
			$IndexNumber = 0
			ForEach($Index in $Table.Indexes) {
			Write-Progress -Id 2 -Activity 'Indexes' -Status $index.Name -PercentComplete $($IndexNumber / $Table.Indexes.Count * 100)
				If($Index.IsDisabled -eq $true) {
					"Skipped {0}.{1}.{2}.{3} because it is disabled" -f $SqlServer, $Database, $Table, $Index
					Continue
				}
				ForEach($PhysicalPartition in $Index.PhysicalPartitions) {
					$PhysicalPartition.DataCompression = [Microsoft.SqlServer.Management.Smo.DataCompressionType]::None
					If($Index.IsXmlIndex -eq $true) {
						"Without data compression because {0}.{1}.{2}.{3} is an XML index" -f $SqlServer, $Database, $Table, $Index
					}
					ElseIf($SqlServer.EngineEdition -ne $EnterpriseEdtion) {
						"Without data compression because {0} isn't Enterprise Edtion" -f $SqlServer
					}
					Else {
						$PhysicalPartition.DataCompression = [Microsoft.SqlServer.Management.Smo.DataCompressionType]::Page
					}
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