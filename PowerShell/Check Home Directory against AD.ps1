$HomeBaseDirectory = '\\future.lan\homedir$\utr-her-users\'
$HomeDirectories = Get-ChildItem -Path $HomeBaseDirectory | ?{$_.PsIsContainer -eq $true}
$DefaultNamingContext = ([ADSI]"LDAP://RootDSE").defaultNamingContext
$DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher $DefaultNamingContext
[Void]$DirectorySearcher.PropertiesToLoad.Add('homedirectory')
[Void]$DirectorySearcher.PropertiesToLoad.Add('samaccountname')
ForEach($HomeDirectory in $HomeDirectories) {
	$Result = New-Object PsObject
	$Result | Add-Member -MemberType NoteProperty -Name 'SearchedHome' -Value $("{0}" -f $HomeDirectory.FullName)
	$DirectorySearcher.Filter = '(homedirectory=*{0})' -f $($homeDirectory.Name -replace '^(.*)\.V2$','$1')
	$FoundUser = $DirectorySearcher.FindOne()
	$Username = ''
	$Configuredhome = ''
	If($FoundUser -ne $null) {
		$Username = $($FoundUser.Properties['samaccountname'] -join ',')
		$Configuredhome = $($FoundUser.Properties['homedirectory'] -join ',')
	}
	$Result | Add-Member -MemberType NoteProperty -Name 'Username' -Value $Username
	$Result | Add-Member -MemberType NoteProperty -Name 'ConfiguredHome' -Value $Configuredhome
	$Result
}
