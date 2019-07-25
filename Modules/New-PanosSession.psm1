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
             Mandatory = $false,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [Int]$Port=443,

        [Parameter(
             Position = 2,
             Mandatory = $false,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [String]$VirtualSystem="vsys1",

        [Parameter(
             Position = 3,
             Mandatory = $true,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [PSCredential]$Credential,

        [Parameter(
             Position = 4,
             Mandatory = $false,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [Switch]$SkipCertificateCheck
    )

    Try{
        $username = $Credential.GetNetworkCredential().username
        $password = $Credential.GetNetworkCredential().password

        $params = @{
            Uri = "https://$($FirewallName):$($Port)/api/?type=keygen&user=$($username)&password=$($password)"
            Method = "Get"
            SkipCertificateCheck = $SkipCertificateCheck
        }

        $response = $(Invoke-RestMethod @params).response

        $response | ForEach-Object {
            if($response.status = "success"){
                $session = [Session]@{
                    FirewallName = $FirewallName
                    Port = $Port
                    VirtualSystem = $VirtualSystem
                    ApiKey = $_.result.key
                }

                Write-Output $session
            }
            else{
                throw $response
            }
        }
    }
    Catch{
        Write-Error $_.Exception
    }
}
