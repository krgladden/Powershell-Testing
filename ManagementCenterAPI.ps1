Function Invoke-BasicAuth{
[cmdletbinding()]
param(
[parameter(mandatory=$true)]
[ValidateNotNullOrEmpty()]
[System.Management.Automation.PSCredential]
[System.Management.Automation.credential()]
$Credential = [System.Management.Automation.PSCredential]::empty
)
process{
$pw = $Credential.GetNetworkCredential().Password
$user = $Credential.Username
$pair = "${user}:${pw}"
$RESTheaders = @{ "Authorization" = "Basic " + [System.Convert]::tobase64string([System.text.encoding]::ASCII.GetBytes($pair))}
$RESTheaders}
        }




Function Query-ManagementCenter{
[cmdletbinding()]
param(
[parameter(ValueFromPipeline)]
[validateset("NRFK","SDNI","All")]
[string[]]
$Site="All",



[parameter(Mandatory,
ValueFromPipeline)]
[validateset("Devices","System","Jobs")]
[string[]]
$APIcall,



[parameter(Mandatory,
ValueFromPipeline)]
[hashtable]$APIHeader

)
process{


Switch ($Site){
"all" {$MCsite = @('sdni**', 'nrfk**'); write-verbose "All Sites Selected."}
"nrfk" {$MCsite = 'nrfk**'; write-verbose "MCsite NRFK Selected"}
"sdni" {$MCsite = 'sdni**'; write-verbose "MCsite SDNI Selected"}
       }

Switch ($APIcall){
        "Devices" {$APIset = 'devices/health'
                  }
        "System"  {$APIset = 'system/version'
                  }
         "Jobs"   {$APIset = 'jobs'
                  }
    }	

write-verbose "$Site(s) selected."
write-verbose "$APIcall check called."

Foreach ($mc in $MCsite){
write-host "$($mc) being queried."
$APIData = Invoke-restmethod -Uri "https://$($MC):8082/api/$APIset" -Headers $APIHeader -contenttype "application/json"
$DataCalled += $APIdata
        }
$DataCalled
    }
}

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

$DataCalled = $null
$SelectedData = $Null
$APIData = $Null
$SelHost = @{Name ="Hostname";Expression={$_.name}}

$headers = (Invoke-BasicAuth)


$Datacalled = Query-ManagementCenter -APIHeader $headers -APIcall Devices

$Datacalled | Select-Object -property $SelHost -ExpandProperty Health | Out-GridView

