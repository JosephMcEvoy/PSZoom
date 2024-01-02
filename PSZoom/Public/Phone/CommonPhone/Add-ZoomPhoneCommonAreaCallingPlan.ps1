<#

.SYNOPSIS
Use this API to assign calling plans to a common area.
             
.PARAMETER CommonAreaId
Common area ID or common area extension ID.

.PARAMETER LicenseType
License Type that is to applied to target phone account.
Use following command to get available license types for Zoom instance.
Get-ZoomPhoneCallingPlans

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Add-ZoomPhoneCommonAreaCallingPlan -CommonAreaId "4se5dr6ft7gy8n" -Type 200

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/assignCallingPlansToCommonArea

.LINK
https://developers.zoom.us/docs/api/rest/other-references/plans/

#>

function Add-ZoomPhoneCommonAreaCallingPlan {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    Param(
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'common_Area_Id')]
        [string[]]$CommonAreaId,

        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [Alias('License_Type')]
        [int]$LicenseType,

        [switch]$PassThru
    )
    
    process {
        $CommonAreaId | ForEach-Object {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/common_areas/$_/calling_plans"
            $RequestBody = @{ }
            $ChosenLicense = @{ }


            $KeyValuePairs = @{
                'type'    = $LicenseType
            }

            $KeyValuePairs.Keys | ForEach-Object {
                if (-not ([string]::IsNullOrEmpty($KeyValuePairs.$_))) {
                    $ChosenLicense.Add($_, $KeyValuePairs.$_)
                }
            }

            $ChosenLicense = @($ChosenLicense)

            $RequestBody.Add("calling_plans", $ChosenLicense)

            $RequestBody = $RequestBody | ConvertTo-Json

$Message = 
@"

Method: POST
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@

            if ($pscmdlet.ShouldProcess($Message, $CommonAreaId, "Adding calling plan $LicenseType")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method POST
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $UserId
        }
    }
}
