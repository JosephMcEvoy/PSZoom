<#

.SYNOPSIS
Use this API to unassign a calling plan from the common area.

.PARAMETER CommonAreaId
Common area ID or common area extension ID.

.PARAMETER LicenseType
Plan number to remove.

.PARAMETER RemoveAllPlans
Switch to remove all calling plans from device.

.PARAMETER PassThru
Switch to pass CommonAreaIds back to user.

.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.

.EXAMPLE
Remove-ZoomPhoneCommonAreaCallingPlan -CommonAreaId "n9uyb8ytv7rc6e" -LicenseType 200

.EXAMPLE
Remove-ZoomPhoneCommonAreaCallingPlan -CommonAreaId "n9uyb8ytv7rc6e" -RemoveAllPlans

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/unassignCallingPlansFromCommonArea

#>

function Remove-ZoomPhoneCommonAreaCallingPlan {    
    [CmdletBinding(SupportsShouldProcess = $True)]
    [CmdletBinding(DefaultParameterSetName="SinglePlan")]
    Param(
        [Parameter(
            ParameterSetName = "SinglePlan",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Parameter(
            ParameterSetName = "AllPlans",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('id', 'common_Area_Id')]
        [string[]]$CommonAreaId,


        [Parameter(
            ParameterSetName = "SinglePlan",
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('type')]
        [int]$LicenseType,


        [Parameter(
            ParameterSetName = "AllPlans",
            Mandatory = $True
        )]
        [switch]$RemoveAllPlans,


        [switch]$PassThru
    )
    
    

    process {
        
        switch ($PSCmdlet.ParameterSetName) {

            "SinglePlan" {

                Foreach($CommonArea in $CommonAreaId){           

                    $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/common_areas/$CommonArea/calling_plans/$LicenseType"


$Message = 
@"

Method:  Delete
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@


                    if ($pscmdlet.ShouldProcess($Message, $CommonArea, "Remove calling plan $LicenseType")) {
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
            "AllPlans" {

                Foreach($CommonArea in $CommonAreaId){

                    # Grab Common Area's info
                    $CurrentCommonAreaInfo = Get-ZoomPhoneCommonArea -CommonAreaId $CommonArea

                    # Check if there is a calling plan assigned
                    if ([bool]($CurrentCommonAreaInfo.PSobject.Properties.name -match "calling_plans")){

                        # Capture all the 
                        $CurrentCommonAreaInfo | Select-Object -ExpandProperty "calling_plans" | Select-Object -ExpandProperty "type" | ForEach-Object {

                            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/common_areas/$CommonArea/calling_plans/$_"


$Message = 
@"

Method:  Delete
URI: $($Request | Select-Object -ExpandProperty URI | Select-Object -ExpandProperty AbsoluteUri)
Body:
$RequestBody
"@



                            if ($pscmdlet.ShouldProcess($Message, $CommonArea, "Remove calling plan $CurrentLicense")) {
                                $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method Delete

                                if (-not $PassThru) {
                                    Write-Output $response
                                }
                            }

                        }

                    }else {
                                    
                        Write-Error "Common Area Phone `"$($CurrentCommonAreaInfo.display_name)`" does not have a calling plan to remove."

                    }


                }

                if ($PassThru) {
                    Write-Output $CommonAreaId
                }

            }

        }

    }

}