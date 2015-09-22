Function New-SqlGmsa {
	Param(
		[String]$Cluster
	  , [String]$Instance
	  , [String]$Service
	  , [String]$ServiceSuffix
	  , [String]$PrincipalsAllowedToRetrieveManagedPassword
	)
	$TextInfo = [System.Globalization.CultureInfo]::CurrentCulture.TextInfo
	$ClusterNumber = $($Cluster -replace '.*?([0-9]+).*?','$1')
	$InstanceNumber = $($Instance -replace '.*?([0-9]+).*?','$1')
	$Service = $TextInfo.ToTitleCase($Service.ToLower())
	$ServiceSuffix = $TextInfo.ToTitleCase($ServiceSuffix.ToLower())
	$Name = $('-svc-cl{0}-sql{1}-{2}' -f $ClusterNumber, $InstanceNumber, $ServiceSuffix).ToLower()
	$SamAccountName = $($('svcSql{0}Cl{1}{2}' -f $InstanceNumber, $ClusterNumber, $ServiceSuffix) -replace '(.{0,15}).*','$1')
	$DNSHostName = '{0}.cchs.local' -f $Name.SubString(1)
	$Description = $('SQL Cluster {0} Instance {1} - {2} Service Account' -f $ClusterNumber, $InstanceNumber, $Service)
	New-ADServiceAccount `
		-Name $Name `
		-SamAccountName $SamAccountName `
		-Path 'OU=SQL Server,OU=Service Accounts,OU=Accounts,OU=Management,DC=cchs,DC=local' `
		-Enabled $true `
		-TrustedForDelegation $true `
		-Description $Description `
		-DNSHostName $DNSHostName `
		-PrincipalsAllowedToRetrieveManagedPassword $PrincipalsAllowedToRetrieveManagedPassword
}
New-SqlGmsa -Cluster 'Cluster06' -Instance 'SQL02' -Service 'Database Engine' -ServiceSuffix 'Db' -PrincipalsAllowedToRetrieveManagedPassword 'CCHS-Cluster06-SQL-Nodes'
New-SqlGmsa -Cluster 'Cluster06' -Instance 'SQL02' -Service 'Agent' -ServiceSuffix 'Ag' -PrincipalsAllowedToRetrieveManagedPassword 'CCHS-Cluster06-SQL-Nodes'