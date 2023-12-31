<#

.SYNOPSIS
Update a specific user Zoom Phone Common Area account.
                    
.PARAMETER CommonAreaId
Unique number used to locate Common Area Phone account.

.PARAMETER PolicyInternationalCallingEnable
If enabled, the common area can use international calling.

.PARAMETER PolicyInternationalCallingReset
If reset, the common area international calling setting resets to the default setting.

.PARAMETER AreaCode
Area code of the common area.

.PARAMETER CostCenter
The cost center the common area belongs to.

.PARAMETER CountryIsoCode
Two-lettered country code.

.PARAMETER Department
The department the common area belongs to.

.PARAMETER DisplayName
Display name of the common area.

.PARAMETER EmergencyAddressId
The emergency location's address ID.

.PARAMETER ExtensionNumber
Extension number of the phone. If the site code is enabled, provide the short extension number instead.

.PARAMETER OutboundCallerId
The user's outbound caller ID phone number in E164 format.

.PARAMETER SiteId
Unique identifier of the site to which the common area desk phone is assigned.

.PARAMETER Timezone
Timezone ID for the common area.


.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Assign new extension number
Update-ZoomPhoneCommonArea -UserId askywakler@thejedi.com -ExtensionNumber 011234567

.EXAMPLE
Change common area phone display name
Update-ZoomPhoneCommonArea -UserId askywakler@thejedi.com -DisplayName "Lobby Phone"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/updateCommonArea


#>

function Update-ZoomPhoneCommonArea {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True,       
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [Alias('id')]
        [string]$CommonAreaId,

        [Parameter()]
        [bool]$PolicyInternationalCallingEnable,

        [Parameter()]
        [bool]$PolicyInternationalCallingReset,

        [Parameter()]
        [int]$AreaCode,

        [Parameter()]
        [string]$CostCenter,

        [Parameter()]
        [string]$CountryIsoCode,

        [Parameter()]
        [string]$Department,

        [Parameter()]
        [string]$DisplayName,

        [Parameter()]
        [string]$EmergencyAddressId,

        [Parameter()]
        [int64]$ExtensionNumber,

        [Parameter()]
        [string]$OutboundCallerId,

        [Parameter()]
        [string]$SiteId,

        [Parameter()]
        [string]$Timezone,


        [switch]$PassThru

    )
    


    process {
        foreach ($ID in $commonAreaId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/common_areas/$ID"


            #region international_calling
                $international_calling = @{ }
                if ($PSBoundParameters.ContainsKey('PolicyInternationalCallingEnable')) {
                    $international_calling.Add("enable", $PolicyInternationalCallingEnable)
                }
                if ($PSBoundParameters.ContainsKey('PolicyInternationalCallingReset')) {
                    $international_calling.Add("reset", $PolicyInternationalCallingReset)
                }
            #endregion international_calling


            #region policy
                $policy = @{ }
                if ($international_calling.Count -ne 0) {
                    $policy.Add("international_calling", $international_calling)
                }
            #endregion policy


            #region body
                $RequestBody = @{ }

                $KeyValuePairs = @{
                    'area_code'              = [string]$AreaCode
                    'cost_center'            = $CostCenter
                    'country_iso_code'       = $CountryIsoCode
                    'department'             = $Department
                    'display_name'           = $DisplayName
                    'emergency_address_id'   = $EmergencyAddressId
                    'extension_number'       = $ExtensionNumber
                    'outbound_caller_id'     = $OutboundCallerId
                    'policy'                 = $policy
                    'site_id'                = $SiteId
                    'timezone'               = $Timezone
                }
    
                $KeyValuePairs.Keys | ForEach-Object {
                    if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                        $RequestBody.Add($_, $KeyValuePairs.$_)
                    }
                }
            #endregion body


            if ($RequestBody.Count -eq 0) {

                throw "Request must contain at least one common area account change."

            }


            $RequestBody = $RequestBody | ConvertTo-Json -Depth 10


$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



        if ($pscmdlet.ShouldProcess($Message, $CommonAreaId, "Update")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH
        
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
