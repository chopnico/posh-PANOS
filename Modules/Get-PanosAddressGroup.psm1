<#
#>
function Get-PanosAddressGroup {
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

    Try{
        $xpath = "/config/devices/entry/vsys/entry[@name='$($Session.VirtualSystem)']/address-group"
        if($Name){ $xpath = "$($xpath)/entry[@name='$($Name)']"}

        $action = "?type=config&action=show&key=$($Session.ApiKey)&xpath=$($xpath)"

        $params = @{
            Uri = "https://$($Session.FirewallName):$($Session.Port)/api/$($action)"
            Method = "Get"
            SkipCertificateCheck = $SkipCertificateCheck
        }

        $response = $(Invoke-RestMethod @params).response

        function InitializeAddressGroupObject {
            param($Entry)
            $addressGroup = [AddressGroup]@{
                Name = $Entry.name
                Description = $Entry.description
                Tags = $($Entry.tag.member)
            }

            if($Entry."static") {
                $addressGroup.Members = $Entry."static".member | ForEach-Object {
                    $params = @{
                        Session = $Session
                        SkipCertificateCheck = $SkipCertificateCheck
                        Name = $_
                    }
                    Get-PanosAddress @params
                }
                Write-Output $addressGroup
            }
        }
        $response | ForEach-Object {
            if($response.status = "success"){
                if($response.result.entry){
                    InitializeAddressGroupObject -Entry $response.result.entry
                }
                else{
                    $response.result."address-group".entry | ForEach-Object {
                        InitializeAddressGroupObject -Entry $_
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
