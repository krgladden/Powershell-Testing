Function Query-ManagementCenter{
[cmdletbinding()]
param(
[parameter(Mandatory=$true)]
[parameter(ValueFromPipeline)]
[string[]]
$MCSite,

[parameter(ValueFromPipeline)]
[int]
$port=8082,


[parameter(Mandatory=$true)]
[parameter(ValueFromPipeline)]
[validateset("Devices","System","Jobs")]
[string[]]
$APIcall,



[parameter(Mandatory=$true)]
[parameter(ValueFromPipeline)]
[hashtable]$APIHeader


)
process{



Switch ($APIcall){
        "Devices" {$APIset = 'devices/health'
                  }
        "System"  {$APIset = 'system/version'
                  }
         "Jobs"   {$APIset = 'jobs'
                  }
    }	

write-verbose "$MCSite(s) selected."
write-verbose "$APIcall check called."

Foreach ($mc in $MCsite){
write-host "$($mc) being queried."
$APIData = Invoke-restmethod -Uri "https://$($MC):$($port)/api/$APIset" -Headers $APIHeader -contenttype "application/json"
$DataCalled += $APIdata
        }
$DataCalled
    }
}
