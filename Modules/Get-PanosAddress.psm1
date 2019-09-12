<#
#>
function Get-PanosAddress {
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

        $address = [Address]@{
            Name = $Entry.name
            Description = $Entry.description
            Tags = $($Entry.tag.member)
        }

        if($Entry."ip-netmask") {
            $address.Address = $Entry."ip-netmask"
            $address.Type = "ip-netmask"
        } elseif($Entry."ip-range") {
            $address.Address = $Entry."ip-range"
            $address.Type = "ip-range"
        } elseif($Entry."fqdn") {
            $address.Address = $Entry."fqdn"
            $address.Type = "fqdn"
        }

        return $address
    }

    Try{
        $xpath = "/config/devices/entry/vsys/entry[@name='$($Session.VirtualSystem)']/address"

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
                }elseif($response.result.address.entry){
                    $response.result.address.entry | ForEach-Object {
                        Write-Output $(Initialize -Entry $_)
                    }
                }else {
                        return $null
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
