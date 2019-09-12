<#
.SYNOPSIS
Gets a list of address groups from a Palo Alto firewall.

.DESCRIPTION
Gets a list of address groups from a Palo Alto firewall.
You can filter your results by name
#>
function Get-PanosAddressGroup {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName = 'ByName')]
        [Session]$Session,

        [Parameter(Position = 1, Mandatory = $false, ParameterSetName = 'ByName')]
        [String]$Name,

        [Parameter(Position = 2, Mandatory = $true, ParameterSetName = 'Default')]
        [Parameter(Position = 2, Mandatory = $false, ParameterSetName = 'ByName')]
        [Switch]$SkipCertificateCheck
    )

    function Initialize {
        param(
            [System.Xml.XmlElement]$Entry
        )

        if($Entry."static") {
            $addressGroup = [StaticAddressGroup]@{
                Name = $Entry.name
                Description = $Entry.description
                Tags = $($Entry.tag.member)
            }
            $addressGroup.Members = $Entry."static".member | ForEach-Object {
                $params = @{
                    Session = $Session
                    SkipCertificateCheck = $SkipCertificateCheck
                    Name = $_
                }
                Get-PanosAddress @params
            }
            return $addressGroup
        }
        elseif($Entry."dynamic"){
            $addressGroup = [DynamicAddressGroup]@{
                Name = $Entry.name
                Description = $Entry.description
                Tags = $($Entry.tag.member)
            }
        }
    }

    Try{
        $xpath = "/config/devices/entry/vsys/entry[@name='$($Session.VirtualSystem)']/address-group"

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
                elseif($response.result."address-group".entry){
                    $response.result."address-group".entry | ForEach-Object {
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
