New-IseSnippet -Title Use-BasicAuth -Description "A template for using basic authentication with REST API." -Text "<#
$cred = Get-Credential
$pw = $cred.GetNetworkCredential().Password
$user = $cred.UserName
$pair = "${user}:${pw}"
$bytes = [System.text.encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::tobase64string($bytes)
$BasicAuthValue = "Basic $base64"
$headers = @{ Authorization = $BasicAuthValue }
#>"
