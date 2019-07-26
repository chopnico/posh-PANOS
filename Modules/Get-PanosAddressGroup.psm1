<#
.SYNOPSIS
Gets a list of address groups from a Palo Alto firewall.

.DESCRIPTION
Gets a list of address groups from a Palo Alto firewall.
You can filter your results by name, tag, or 

.PARAMETER Name
Specifies the file name.

.PARAMETER Extension
Specifies the extension. "Txt" is the default.

.INPUTS

None. You cannot pipe objects to Add-Extension.

.OUTPUTS

System.String. Add-Extension returns a string with the extension
or file name.

.EXAMPLE

PS> extension -name "File"
File.txt

.EXAMPLE

PS> extension -name "File" -extension "doc"
File.doc

.EXAMPLE

PS> extension "File" "doc"
File.doc

.LINK

http://www.fabrikam.com/extension.html

.LINK

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

    Try{
        $xpath = "/config/devices/entry/vsys/entry[@name='$($Session.VirtualSystem)']/address-group"

        if($Name){ $xpath = "$($xpath)/entry[@name='$($Name)']" }

        $action = "?type=config&action=show&key=$($Session.ApiKey)&xpath=$($xpath)"

        $params = @{
            Uri = "https://$($Session.FirewallName):$($Session.Port)/api/$($action)"
            Method = "Get"
            SkipCertificateCheck = $SkipCertificateCheck
        }

        $response = $(Invoke-RestMethod @params).response

        $response | ForEach-Object {
            if($response.status = "success"){
                if($response.result.entry){
                    Initialize -Entry $response.result.entry
                }
                elseif($response.result."address-group".entry){
                    $response.result."address-group".entry | ForEach-Object {
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
