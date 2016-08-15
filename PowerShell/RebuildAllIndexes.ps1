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
	"This script required at least SQL Server 2008, {0} is older" -f $Instance
	Exit
}
$All = [Microsoft.SqlServer.Management.Smo.StatisticsTarget]::All
$FullScan = [Microsoft.SqlServer.Management.Smo.StatisticsScanType]::FullScan
$PageCompression = [Microsoft.SqlServer.Management.Smo.DataCompressionType]::Page
$NoCompression = [Microsoft.SqlServer.Management.Smo.DataCompressionType]::None
$DatabaseNumber = 0
ForEach($Database in $SqlServer.Databases) {
	If((-Not[String]::IsNullOrEmpty($DB)) -and ($DB -ne $Database.Name)) {
		Continue
	}
	Write-Progress -Id 0 -Activity 'Databases' -Status $Database.Name -PercentComplete $($DatabaseNumber / $SqlServer.Databases.Count * 100)
	$TableNumber = 0
	ForEach($Table in $Database.Tables) {
		Write-Progress -Id 1 -Activity 'Tables' -Status $Table.Name -PercentComplete $($TableNumber / $Database.Tables.Count * 100)
		If(@('master','msdb','tempdb','model') -Contains $Database.Name -and $SkipSystem) {
			Continue
		}
		ElseIf(@('master','msdb','tempdb','model') -NotContains $Database.Name -And $SkipUser) {
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
					$PhysicalPartition.DataCompression = $NoCompression
					If($Index.IsXmlIndex -eq $true) {
						"Without data compression because {0}.{1}.{2}.{3} is an XML index" -f $SqlServer, $Database, $Table, $Index
					}
					ElseIf($SqlServer.EngineEdition -ne $EnterpriseEdtion) {
						"Without data compression because {0} isn't Enterprise Edtion" -f $SqlServer
					}
					Else {
						$PhysicalPartition.DataCompression = $PageCompression
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
