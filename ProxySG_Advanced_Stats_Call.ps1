

function Format-Color([hashtable] $Colors = @{}, [switch] $SimpleMatch) {
	$lines = ($input | Out-String) -replace "`r", "" -split "`n"
	foreach($line in $lines) {
		$color = ''
		foreach($pattern in $Colors.Keys){
			if(!$SimpleMatch -and $line -match $pattern) { $color = $Colors[$pattern] }
			elseif ($SimpleMatch -and $line -like $pattern) { $color = $Colors[$pattern] }
		}
		if($color) {
			Write-Host -ForegroundColor $color $line
		} else {
			Write-Host $line
		}
	}
}

<#
Format-Color accepts the following colors: 
Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White
#>


#region SSL Certificate Validation
#The following lines are to disable SSL certificate validation, since the proxies all have self signed certificates

function Set-CertPolicy{


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
}
#endregion


#region Credentials



#Currently, WebClient has been depreciated for this script. Leaving this in in case this changes.
#$Webclient = New-Object System.Net.WebClient
#$webclient.Credentials = $cred.GetNetworkCredential()


#region Command Input

#endregion Command Input


#region selected order of headers for report



#endregion


#$UserWin collects the username of the Windows user currently logged in, not whoever is logged into the terminal.

#endregion


Function Query-ProxySG{
[cmdletbinding()]
Param (

[parameter(mandatory=$true)]
[validateset("JAXS","NRFK","SDNI","BREM","PRLH","Tier_1")]
[String]$Groupselect,

[parameter(mandatory=$true)]
[ValidateNotNullOrEmpty()]
[System.Management.Automation.PSCredential]
[System.Management.Automation.credential()]
$Credential = [System.Management.Automation.PSCredential]::empty

)


$pw = $Credential.GetNetworkCredential().Password
$user = $Credential.UserName
$Headers = @("Proxy Hostname","Total Connections","Total Users","TIME_WAIT Connections","CPU Usage","Time")
$CMDListInput = "show ip-stats tcp
show advanced-url /tcp/users
show cpu
exit
exit"

#region Accepted Colors

$SiteColor = @{"*NRFK*"='Cyan';"*SDNI*"='Magenta';"*JAXS*"='DarkGreen';"*BREM*"='Yellow';"*PRLH*"='Gray'}
#endregion

$groupselect = read-host "Select which group you want to scan"
#region Host Arrays
$Hostlist=[pscustomobject]@{
        JAXS = @(**)
        NRFK = @("**)
        BREM = @(**)
        PRLH = @(**)
        SDNI = @(**)
        }
#endregion



$Proxyhosts = $Hostlist.$($groupselect)

Write-Host "$groupselect selected."


}




Function Generate-Report{
[cmdletbinding()]
Param (
    [ValidateScript({
        if(-NOT $_ | Test-Path){
            throw "Folder does not exist."
            
        }

            return $True
        
       })]
        $ReportFilePath = "C:\Users\$((get-wmiobject -class win32_computersystem).Username.split('\')[1])\Documents"



)

        $Report        = "$($reportfilepath)\TCPConnections_$(get-date -f yyyy-MM-dd).csv"
        $selectedorder = "Proxy Hostname","Total Connections","Total Users","TIME_WAIT Connections","Time"
        $Headers       = @("Proxy Hostname","Total Connections","Total Users","TIME_WAIT Connections","Time")









#region Report File Validation


if (test-path $Report)
        {
        write-host "File $($Report) exists. Appending results of test to this location."
        }
else
        {
        write-host "Report file does not exist. Generating $($Report)"
        $psobject = new-object psobject
        foreach($header in $headers)
        {add-member -InputObject $psobject -MemberType NoteProperty -Name $header -value ""
        }
         $psobject | export-csv $Report -NoTypeInformation
         write-host "$($Report) generated."
        }


}

#endregion Report File Validation

#region Header Generation
$psobject = new-object psobject
foreach($header in $headers)
{
add-member -InputObject $psobject -MemberType NoteProperty -Name $header -value ""
}
#endregion Header Generation


$psobject | format-table



while (1 -ne 0){
foreach($Proxy in $ProxyHosts){

Function Call-ProxyData{
[cmdletbinding()]
Param (
[parameter(mandatory=$true)]
[String]$proxy,

[parameter(mandatory=$true)]
[String]$user,

[parameter(mandatory=$true)]
[securestring]$pw,

[parameter(mandatory=$true)]
[String]$CMDListInput,

[parameter(mandatory=$false)]
[String]$report




)



$staging = @{}
 $Headers      = @("Proxy Hostname","Total Connections","Total Users","CPU Usage","TIME_WAIT Connections","Time")

#region TCP Connections Collection
Write-Progress -activity "Parsing $Proxy." -Status "Downloading $Proxy TCP connections data."


$TCPConn =(echo "y" | C:\putty\PLINK.EXE -v -ssh -C $Proxy -l $user -pw $pw $CMDListInput) 2>&1


#endregion TCP Connections Collection




#region Data Parsing


Write-Progress -activity "Parsing $Proxy." -Status "Searching $Proxy data for requested strings."

foreach ($header in $headers){
switch ($header){
"Total Connections"    {$ConnSumm = $($($TCPConn | Select-String -Pattern "Number of established TCP connections" -CaseSensitive) -split " ")[-1]
                  }

"Total Users"          {$ConnSumm = $($($TCPConn | Select-String -Pattern "Number of concurrent users" -CaseSensitive) -split " ")[-1]
                  }

"TIME_WAIT Connections"{$ConnSumm = $($($TCPConn | Select-String -Pattern "Entries in TCP time wait queue" -CaseSensitive) -split " ")[-1]
                  }

"CPU Usage"            {$ConnSumm = $($($TCPConn | Select-String -Pattern "Current CPU Usage" -CaseSensitive) -split " ")[-1]
                  }

"Time"                 {$Connsumm = (get-date)
                  }

"Proxy Hostname"       {$connsumm = $proxy}
              }
 $Staging.add($header,$ConnSumm)
}
$staging = [pscustomobject]$staging
$staging
#endregion


#region Report Generation



$staging | format-table -HideTableHeaders -property $Headers | format-color -SimpleMatch $SiteColor


Write-Progress -activity "Parsing $Proxy." -Status "Appending $Proxy data to report(s)."


939
export-csv $Report -inputobject $staging -append -Force


#endregion

}


}





Query-ProxySG -Groupselect NRFK

