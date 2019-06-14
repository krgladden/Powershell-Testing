
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

$MCSite = read-host "Select Management Center Site. Input as nrfk, sdni, or all"


write-host $mcsite1 $mcsite2
$cred = Get-Credential -Message "Please input Username and Password"
$pw = $cred.GetNetworkCredential().Password
$user = $cred.UserName
$pair = "${user}:${pw}"
$bytes = [System.text.encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::tobase64string($bytes)
$BasicAuthValue = "Basic $base64"
$headers = @{ Authorization = $BasicAuthValue }



$testing = Invoke-restmethod -Uri 'https://***:8082/api/devices/health' -Headers $headers -contenttype "application/json"

$testing | select-object @{Name = "Hostname"; Expression =  {$_.name}} -ExpandProperty health
