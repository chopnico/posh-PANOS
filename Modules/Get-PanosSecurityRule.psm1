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

        function GetPanosAddress{
            param($Name)

            if(-not [System.Net.IPAddress]::TryParse($Name, [ref]$null)){
                $Name | ForEach-Object {
                    $params = @{
                        Session = $Session
                        SkipCertificateCheck = $SkipCertificateCheck
                        Name = $_
                    }
                    Get-PanosAddress @params
                }
            } else{
                return [Address]@{
                    Name = $Name
                    Address = $Name
                }
            }
        }

        $securityRule = [SecurityRule]@{
            Name = $Entry.name
            SourceUser = $Entry.'source-user'.member
            Category = $Entry.category.member
            Application = $Entry.application.member
            Service = $Entry.service.member
            HipProfiles = $Entry.'hip-profiles'.member
            Action = $Entry.action
            Description = $Entry.description
        }

        $securityRule.To = $Entry.to.member | Foreach-Object { GetPanosAddress -Name $_ }
        $securityRule.From = $Entry.from.member | Foreach-Object { GetPanosAddress -Name $_ }
        $securityRule.Source = $Entry.source.member | Foreach-Object { GetPanosAddress -Name $_ }
        $securityRule.Destination = $Entry.destination.member | Foreach-Object { GetPanosAddress -Name $_ }

        return $securityRule
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
