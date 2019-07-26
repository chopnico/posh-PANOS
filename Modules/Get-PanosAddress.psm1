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

        if($Entry."ip-netmask") { $address.IPAddress = $Entry."ip-netmask" }
        elseif($Entry."ip-range") { $address.IPAddress = $Entry."ip-range" }
        elseif($Entry."fqdn") { $address.IPAddress = $Entry."fqdn" }

        Write-Output $address
    }

    Try{
        $xpath = "/config/devices/entry/vsys/entry[@name='$($Session.VirtualSystem)']/address"
        if($Name){ $xpath = "$($xpath)/entry[@name='$($Name)']"}

        $action = "?type=config&action=show&key=$($Session.ApiKey)&xpath=$($xpath)"

        $params = @{
            Uri = [Uri]"https://$($Session.FirewallName):$($Session.Port)/api/$($action)"
            Method = "Get"
            SkipCertificateCheck = $SkipCertificateCheck
        }

        $response = $(Invoke-RestMethod @params).response

        $response | ForEach-Object {
            if($response.status = "success"){
                if($response.result.entry){
                    Initialize -Entry $response.result.entry
                }
                else{
                    $response.result.address.entry | ForEach-Object {
                        Initialize -Entry $_
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
