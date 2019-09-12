<#
#>
function Get-PanosSecurityRule{
    param (
        [Parameter(
             Position = 0,
             Mandatory = $true,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [Session]$Session,

        [Parameter(
             Position = 1,
             Mandatory = $false,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [String]$Name,

        [Parameter(
             Position = 2,
             Mandatory = $false,
             ValueFromPipeLine = $false,
             ValueFromPipeLineByPropertyName = $false)]
        [Switch]$SkipCertificateCheck
    )

    function Initialize {
        param($Entry)

        Write-Output $Entry
    }

    Try{
        $xpath = "/config/devices/entry/vsys/entry[@name='$($Session.VirtualSystem)']/rulebase/security"

        if($Name){
            $encodedName = [System.Web.HttpUtility]::UrlEncode($Name)
            $xpath = "$($xpath)/rules/entry[@name='$($encodedName)']"
        }

        $path = "?type=config&action=show&key=$($Session.ApiKey)&xpath=$($xpath)"

        $uri = [Uri]"https://$($Session.FirewallName):$($Session.Port)/api/$($path)"

        $params = @{
            Uri = $uri.AbsoluteUri
            Method = "Get"
            SkipCertificateCheck = $SkipCertificateCheck
        }

        $response = $(Invoke-RestMethod @params).response

        $response | ForEach-Object {
            if($response.status = "success"){
                if($response.result.entry){
                    Write-Output $(Initialize -Entry $response.result.entry)
                }
                else{
                    $response.result.security.rules.entry | ForEach-Object {
                        Write-Output $(Initialize -Entry $_)
                    }
                }
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
