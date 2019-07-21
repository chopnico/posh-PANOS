<#
#>
function New-PanosSession {
    [CmdletBinding()]
    param (
        [Parameter(
             Position = 0,
             Mandatory = $true,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [String]$FirewallName,

        [Parameter(
             Position = 1,
             Mandatory = $true,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [PSCredential]$Credential,

        [Parameter(
             Position = 2,
             Mandatory = $false,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [PSCredential]$SkipCertificateCheck,
    )

    Try{
        $username = $Credential.GetNetworkCredential().username
        $password = $Credential.GetNetworkCredential().password

        $response = Invoke-RestMethod `
          -Uri "https://$($FirewallName)/api/?type=keygen&user=$($username)&password=$($password)" `
          -Method Get `
          -ContentType "application/json"

        Write-Output $response
    }
    Catch{
        Write-Error $_.Exception
    }
}
