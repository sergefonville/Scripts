[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO')

Function Get-AvailabilityResources {
	Get-ADComputer -LDAPFilter "(&(CN=SQL-Cluster*)(ObjectClass=Computer))" |
		%{Get-ClusterResource -Cluster $_.Name |
		?{$_.ResourceType -eq 'SQL Server Availability Group'}} |
		%{Get-SqlServerConnection -Server $_.Name}
}

Function Get-AvailabilityGroups {
	Param(
		[Parameter(Mandatory=$true)]
		[Microsoft.SqlServer.Management.Smo.Server]$Server
	)
	$Server.AvailabilityGroups
}

Function Get-AvailabilityReplicas {
	Param(
		[Parameter(Mandatory=$true)]
		[Microsoft.SqlServer.Management.Smo.AvailabilityGroup]$AvailabilityGroup
	)
	$AvailabilityGroup.AvailabilityReplicas
}

Function Get-SqlServerConnection {
	Param(
		[Parameter(Mandatory=$true)]
		[String]$Server
	)
	New-Object Microsoft.SqlServer.Management.Smo.Server($Server)
}

Function Get-Jobs {
	Param(
		[Parameter(Mandatory=$true)]
		[Microsoft.SqlServer.Management.Smo.Server]$Server
	)
	$Server.JobServer.Jobs
}

Function Synchronize-Jobs {
	Param(
		[Parameter(Mandatory=$true)]
		[Microsoft.SqlServer.Management.Smo.Server]$LeftServer
	  , [Parameter(Mandatory=$true)]
		[Microsoft.SqlServer.Management.Smo.Server]$RightServer
	)
	$LeftJobs = Get-Jobs -Server $LeftServer
	$RightJobs = Get-Jobs -Server $RightServer
	ForEach($LeftJob in $LeftJobs) {
	
	}
}

$AvailabilityGroups = Get-AvailabilityResources | %{Get-AvailabilityGroups -Server $_}
ForEach($AvailabilityGroup in $AvailabilityGroups) {
	$AvailabilityReplicas = Get-AvailabilityReplicas -AvailabilityGroup $AvailabilityGroup
	$LeftReplica = $AvailabilityReplicas[0]
	$RightReplica = $AvailabilityReplicas[1]
	$LeftServer = Get-SqlServerConnection -Server $LeftReplica.Name
	$RightServer = Get-SqlServerConnection -Server $RightReplica.Name
	Synchronize-Jobs -LeftServer $LeftServer -RightServer $RightServer
}

