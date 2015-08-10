$DatabaseHosts = Get-Content .\databasehosts.txt
ForEach($DatabaseHost in $DatabaseHosts) {
    [System.Net.Dns]::GetHostEntry($DatabaseHost) | Select-Object HostName, @{Name='IPAddress';Expression={$_.AddressList}}
}
