<#

.SYNOPSIS
Create a Common area phone account.
              
.PARAMETER CallingPlansType
Zoom Phone calling plan number.

.PARAMETER CountryIsoCode
Two-lettered country code.

.PARAMETER DisplayName
Display name of the common area. Enter at least 3 characters.

.PARAMETER ExtensionNumber
Extension number assigned to the common area. If the site code is enabled, provide the short extension number instead.

.PARAMETER SiteId
Unique identifier of the site to which the common area desk phone is assigned.

.PARAMETER Timezone
Timezone ID for the common area.


.OUTPUTS
Outputs object

.EXAMPLE
Create new common area account
New-ZoomPhoneCommonArea -CallingPlansType 200 -CountryIsoCode "US" -DisplayName "Lobby" -ExtensionNumber 011234567 -SiteId "x3c4v5b6n7ds" -Timezone "America/Los_Angeles"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/addCommonArea


#>

function New-ZoomPhoneCommonArea {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(Mandatory = $True)]
        [string]$DisplayName,

        [Parameter()]
        [int]$CallingPlansType,

        [Parameter()]
        [string]$CountryIsoCode,

        [Parameter()]
        [int64]$ExtensionNumber,

        [Parameter()]
        [string]$SiteId,

        [Parameter()]
        [string]$Timezone,

        [switch]$PassThru

    )
    


    process {
        foreach ($ID in $commonAreaId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/common_areas"



            #region calling_plans
                $calling_plans_array = @( )
                $calling_plans = @{ }
                if ($PSBoundParameters.ContainsKey('CallingPlansType')) {
                    $calling_plans.Add("type", $CallingPlansType)
                    $calling_plans_array.Add($calling_plans)
                }
            #endregion calling_plans


            #region body
                $RequestBody = @{ }

                $KeyValuePairs = @{
                    'calling_plans'          = $calling_plans_array
                    'country_iso_code'       = $CountryIsoCode
                    'display_name'           = $DisplayName
                    'extension_number'       = $ExtensionNumber
                    'site_id'                = $SiteId
                    'timezone'               = $Timezone
                }
    
                $KeyValuePairs.Keys | ForEach-Object {
                    if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
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



        if ($pscmdlet.ShouldProcess($Message, $DisplayName, "Create common area account")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }


        if ($PassThru) {
            Write-Output $commonAreaId
        }
    }
}
