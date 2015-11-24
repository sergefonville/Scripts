$ProfileBaseDirectory = 'Path to check'
$ProfileDirectories = Get-ChildItem -Path $ProfileBaseDirectory | ?{$_.PsIsContainer -eq $true}
$DefaultNamingContext = ([ADSI]"LDAP://RootDSE").defaultNamingContext
$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher $DefaultNamingContext
[Void]$DirectorySearcher.PropertiesToLoad.Add('profilepath')
[Void]$DirectorySearcher.PropertiesToLoad.Add('samaccountname')
ForEach($ProfileDirectory in $ProfileDirectories) {
	$Result = New-Object PsObject
	$Result | Add-Member -MemberType NoteProperty -Name 'SearchedProfile' -Value $("{0}" -f $ProfileDirectory.FullName)
	$DirectorySearcher.Filter = '(profilePath=*{0})' -f $($ProfileDirectory.Name -replace '^(.*)\.V2$','$1')
	$FoundUser = $DirectorySearcher.FindOne()
	$Username = ''
	$ConfiguredProfile = ''
	If($FoundUser -ne $null) {
		$Username = $($FoundUser.Properties['samaccountname'] -join ',')
		$ConfiguredProfile = $($FoundUser.Properties['profilepath'] -join ',')
	}
	$Result | Add-Member -MemberType NoteProperty -Name 'Username' -Value $Username
	$Result | Add-Member -MemberType NoteProperty -Name 'ConfiguredProfile' -Value $ConfiguredProfile
	$Result
}
