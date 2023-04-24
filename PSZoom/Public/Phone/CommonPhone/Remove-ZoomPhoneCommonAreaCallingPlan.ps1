<#

.SYNOPSIS
Use this API to unassign a calling plan from the common area.

.PARAMETER CommonAreaId
Common area ID or common area extension ID.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomPhoneCommonAreaCallingPlan -CommonAreaId "n9uyb8ytv7rc6e"

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/unassignCallingPlansFromCommonArea

#>

function Remove-ZoomPhoneCommonAreaCallingPlan {    
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

        [switch]$PassThru
    )
    


    process {
        $CommonAreaId | ForEach-Object {

            $CurrentLicense = Get-ZoomPhoneCommonArea -CommonAreaId $_ | Select-Object -ExpandProperty "calling_plans" | Select-Object -ExpandProperty "type"

            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$_/calling_plans/$CurrentLicense"


$Message = 
@"

URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@


            if ($pscmdlet.ShouldProcess($Message, $_, "Remove calling plan $CurrentLicense")) {
                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete
        
                if (-not $PassThru) {
                    Write-Output $response
                }
            }
        }

        if ($PassThru) {
            Write-Output $CommonAreaId
        }
    }
}
