<#
#>
function Get-PanosZone{
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
        $zone = [Zone]@{
            Name = $Entry.name
        }

        if($Entry.'enable-user-identification' -eq 'yes'){
            $zone.UserIdEnabled = $true
        }
        else{
            $zone.UserIdEnabled = $false
        }

        if($Entry.network.'layer3'){
            $zone.Network = "layer3"
            $zone.Member = $Entry.network.'layer3'.member
        }

        return $zone
    }

    Try{
        $xpath = "/config/devices/entry/vsys/entry[@name='$($Session.VirtualSystem)']/zone"

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
                }elseif($response.result.zone.entry){
                    $response.result.zone.entry | ForEach-Object {
                        Write-Output $(Initialize -Entry $_)
                    }
                }else{
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
