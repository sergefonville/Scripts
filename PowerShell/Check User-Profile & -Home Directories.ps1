$DefaultNamingContext = ([ADSI]"LDAP://RootDSE").defaultNamingContext
$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher $DefaultNamingContext
$DirectorySearcher.Filter = $("(&(samAccountType={0})(profilePath=*))" -f 805306368)
[Void]$DirectorySearcher.PropertiesToLoad.Add('samaccountname')
[Void]$DirectorySearcher.PropertiesToLoad.Add('profilePath')
[Void]$DirectorySearcher.PropertiesToLoad.Add('homedirectory')
$Results = $DirectorySearcher.FindAll()
$ErrorActionPreference = 'SilentlyContinue'
ForEach($Result in $Results) {
	$DirectoryEntry = $Result.GetDirectoryEntry()
	$User = New-Object PsObject
	$User | Add-Member -MemberType NoteProperty -Name 'Name' -Value $DirectoryEntry.Properties['samaccountname'][0]
	$ProfileDirectory = $false
	$ProfileDirectory = $DirectoryEntry.Properties['profilePath'] -join ','
	$User | Add-Member -MemberType NoteProperty  -Name 'ProfileDirectory' -Value $ProfileDirectory
	$ProfileExists = $(Test-Path $($ProfileDirectory + '*'))
	$User | Add-Member -MemberType NoteProperty  -Name 'ProfileExists' -Value $ProfileExists
	
	$HomeDirectory = $DirectoryEntry.Properties['homedirectory'] -join ','
	$User | Add-Member -MemberType NoteProperty  -Name 'HomeDirectory' -Value $HomeDirectory
	$HomeExists = $false
	$HomeExists = $(Test-Path $($HomeDirectory + '*'))
	$User | Add-Member -MemberType NoteProperty  -Name 'HomeExists' -Value $HomeExists
	$User
}