#The following lines are to disable SSL certificate validation, since the proxies all have self signed certificates
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
$reportfile = "C:\DOWNLOADS\Test_ProxySG_DNS_Queries__$(get-date -f yyyy-MM-dd-HH-mm).csv"

$cred = Get-Credential -Message "Please input Username and password"

$contents = Get-Content "C:\DOWNLOADS\proxy-list.txt"

$columns = "Proxy Hostname,14:00:00,15:00:00,16:00:00,17:00:00,18:00:00,19:00:00,20:00:00,21:00:00,22:00:00,23:00:00,00:00:00,01:00:00,02:00:00,03:00:00,04:00:00,05:00:00,06:00:00,07:00:00,08:00:00,09:00:00,10:00:00,11:00:00,12:00:00,13:00:00"
$columns | Out-File $reportfile


foreach($content in $contents){
$hostname = $content
$r = Invoke-WebRequest -Credential $cred -Uri https://"$hostname":9443/PDM/show-values/http:dwell:count:dns~daily
$r.parsedhtml.getelementsbytagname("TR") |
ForEach-Object {
    ( $_.children |
        Where-Object { $_.tagName -eq "td" } |
            Select-Object -ExpandProperty innerText
             ) -join ","
        }  | Out-File -Encoding ascii "C:\DOWNLOADS\Proxydata\$($hostname)DNStest.csv"
(Get-Content -path "C:\DOWNLOADS\Proxydata\$($hostname)DNStest.csv" | Select-Object -skip 3) | Out-File "C:\DOWNLOADS\Proxydata\$($hostname)DNSfixtst.csv"
(Get-Content "C:\DOWNLOADS\Proxydata\$($hostname)DNSfixtst.csv") | foreach {"$hostname," + $_} | Out-file -Encoding ascii $reportfile -Append
}   
       
       
<#       
        if($datum.tagName -eq "tr"){
            $thisRow = @()
            $cells = $datum.children
            forEach($child in $cells){
                if($child.tagName -eq "td"){
                    $thisRow += $child.innerText
                }
            }
            $thisRow -join ","
        }
    }  | Out-File -Encoding ascii "C:\DOWNLOADS\Test_ProxySG_DNS_Queries__$(get-date -f yyyy-MM-dd-HH-mm).csv"
    #>
