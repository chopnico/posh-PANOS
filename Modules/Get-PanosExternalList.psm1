<#
#>
function Get-PanosExternalList {
    [CmdletBinding()]
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

        $externalList = [ExternalList]@{
            Name = $Entry.name
        }
        if($Entry.'type'.'ip'){
            $externalList.Type = "ip"
            $externalList.Url = $Entry.type.ip.url
            $externalList.Description = $Entry.type.ip.description
        }

        return $externalList
    }

    Try{
        $xpath = "/config/devices/entry/vsys/entry[@name='$($Session.VirtualSystem)']/external-list"

        if($Name){
            $encodedName = [System.Web.HttpUtility]::UrlEncode($Name)
            $xpath = "$($xpath)/entry[@name='$($encodedName)']"
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
                elseif($response.result.'external-list'.entry){
                    $response.result.'external-list'.entry | ForEach-Object {
                        Write-Output $(Initialize -Entry $_)
                    }
                }
                else{
                    return $null
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
