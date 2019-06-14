$cred = Get-Credential -Message "Please input Username and Password"
$pw = $cred.GetNetworkCredential().Password
$user = $cred.UserName
$CASHosts = Get-Content "C:\DOWNLOADS\WIPowershell\cas-list.txt"

$reportfile = "C:\DOWNLOADS\BluecoatData\CASData\CAS_Definition_Dates__$(get-date -f yyyy-MM-dd).csv"
$columns = "Proxy Hostname, AV Date"
$columns | Out-file -Filepath $reportfile -Encoding ascii -Force


foreach ($CASHost in $CASHosts) {
   
$workingdata = (Write-Output "y" | C:\putty\PLINK.EXE $CAShost -l $user -pw $pw "show services symantec")
$PatternDate = $workingdata | Select-String -Pattern "pattern-date"
$DateTimeString = [regex]::Match($PatternDate, '(\d\d\d\d-\d\d-\d\d)')[0].Groups[1].Value
write-host $CASHost, $datetimestring
$ExportData = "$CASHost, $datetimestring"
$ExportData | Out-File -Filepath $reportfile -Append
}

    
