<#

.SYNOPSIS
Create a Auto Receptionist phone account.

.PARAMETER Name
Display name of the Auto Receptionist. Enter at least 3 characters.

.PARAMETER SiteId
Unique identifier of the site to which the Auto Receptionist is assigned.

.OUTPUTS
Outputs object

.EXAMPLE
Create new Auto Receptionist account
New-ZoomPhoneAutoReceptionist -Name "Public_Number-New_York" -SiteId "x3c4v5b6n7ds"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addAutoReceptionist

#>

function New-ZoomPhoneAutoReceptionist {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$Name,

        [Parameter(Mandatory = $True)]
        [string]$SiteId,

        [switch]$PassThru

    )
    
    process {
        foreach ($ID in $AutoReceptionistId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/auto_receptionists"



            #region body
                $RequestBody = @{ }

                $KeyValuePairs = @{
                    'name'           = $Name
                    'site_id'        = $SiteId
                }
    
                $KeyValuePairs.Keys | ForEach-Object {
                    if (-not (([string]::IsNullOrEmpty($KeyValuePairs.$_)) -or ($KeyValuePairs.$_ -eq 0) )) {
                        $RequestBody.Add($_, $KeyValuePairs.$_)
                    }
                }
            #endregion body
            
            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

$Message = 
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

        if ($pscmdlet.ShouldProcess($Message, $Name, "Create Auto Receptionist account")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $AutoReceptionistId
        }
    }
}
