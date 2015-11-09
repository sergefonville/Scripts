[CmdletBinding()]
Param(
	[Parameter(ParameterSetName='Add', Mandatory=$true)]
	[Switch]$Add
  , [Parameter(ParameterSetName='Delete', Mandatory=$true)]
	[Switch]$Delete
  , [Parameter(ParameterSetName='Find', Mandatory=$true)]
	[Switch]$Find
  , [Parameter(ParameterSetName='List', Mandatory=$true)]
	[Switch]$List
  , [Parameter(ParameterSetName='Add', Mandatory=$true)]
	[Parameter(ParameterSetName='Delete', Mandatory=$true)]
	[Parameter(ParameterSetName='Find', Mandatory=$true)]
	[String]$SPN
  , [Parameter(ParameterSetName='Add', Mandatory=$true)]
	[Parameter(ParameterSetName='Delete', Mandatory=$true)]
	[Parameter(ParameterSetName='List', Mandatory=$true)]
	[String]$PrincipalName
)

Function List {
	$DefaultNamingContext = ([ADSI]"LDAP://RootDSE").defaultNamingContext
	$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher $DefaultNamingContext
	$DirectorySearcher.Filter = $("(samAccountName={0})" -f $PrincipalName)
	[Void]$DirectorySearcher.PropertiesToLoad.Add('serviceprincipalname')
	$Results = $DirectorySearcher.FindAll()
	If($Results -eq $null) {
		Write-Error -Message $("No serviceprincipalnames found when searching for '{0}'" -f $PrincipalName)
		Exit
	}
	$Results | %{$_.Properties['serviceprincipalname']} | %{New-Object -TypeName PSObject -Prop @{'serviceprincipalname' = $_}}
}

Function Add {
	$DefaultNamingContext = ([ADSI]"LDAP://RootDSE").defaultNamingContext
	$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher $DefaultNamingContext
	$DirectorySearcher.Filter = $("(samAccountName={0})" -f $PrincipalName)
	$Result = $DirectorySearcher.FindOne()
	If($Result -eq $null) {
		Write-Error -Message $("'{0}' is not a valid principal" -f $PrincipalName)
		Exit
	}
	$DirectoryEntry = $Result.GetDirectoryEntry()
	$DirectoryEntry.Properties['serviceprincipalname'].Add($SPN)
	$DirectoryEntry.CommitChanges()
}

Function Delete {
	$DefaultNamingContext = ([ADSI]"LDAP://RootDSE").defaultNamingContext
	$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher $DefaultNamingContext
	$DirectorySearcher.Filter = $("(&(samAccountName={0})(serviceprincipalname={1}))" -f $PrincipalName, $SPN)
	[Void]$DirectorySearcher.PropertiesToLoad.Add('serviceprincipalname')
	$Result = $DirectorySearcher.FindOne()
	If($Result -eq $null) {
		Write-Error -Message $("'{0}' is not a valid principal and/or '{1}' does not belong to '{0}'" -f $PrincipalName, $SPN)
		Exit
	}
	$DirectoryEntry = $Result.GetDirectoryEntry()
	$DirectoryEntry.Properties['serviceprincipalname'].Remove($SPN)
	$DirectoryEntry.CommitChanges()
}

Function Find {
	$DefaultNamingContext = ([ADSI]"LDAP://RootDSE").defaultNamingContext
	$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher $DefaultNamingContext
	$DirectorySearcher.Filter = $("(serviceprincipalname=*{0}*)" -f $SPN)
	[Void]$DirectorySearcher.PropertiesToLoad.Add('samaccountname')
	[Void]$DirectorySearcher.PropertiesToLoad.Add('serviceprincipalname')
	$SearchResults = $DirectorySearcher.FindAll()
	If($SearchResults -eq $null) {
		Write-Error -Message $("No samaccountnames found when searching for '{0}'" -f $SPN)
		Exit
	}
	ForEach($SearchResult in $SearchResults) {
		$samaccountname = $SearchResult.Properties['samaccountname'] -join ','
		ForEach($ServicePrincipalName in $SearchResult.Properties['serviceprincipalname']) {
			If(-Not $ServicePrincipalName.StartsWith('MSSQLSvc')) {
				Continue
			}
			$Result = New-Object -TypeName PSObject
			$Result | Add-Member -MemberType NoteProperty -Name 'samaccountname' -Value $samaccountname
			$Result | Add-Member -MemberType NoteProperty -Name 'serviceprincipalname' -Value $ServicePrincipalName
			$Result
		}
	}
}

Invoke-Expression -Command $($PsCmdlet.ParameterSetName)