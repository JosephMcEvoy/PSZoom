<#

.SYNOPSIS
List all Zoom Phone calling plans that are enabled for Account.

.DESCRIPTION
List all Zoom Phone calling plans that are enabled for Account.


.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/listCallingPlans
	
.EXAMPLE
Return the list of all Calling plans.
Get-ZoomPhoneCallingPlans
#>

function Get-ZoomPhoneCallingPlan {
    [alias("Get-ZoomPhoneCallingPlans")]
    [CmdletBinding()]
    param ()

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/calling_plans"        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET | Select-Object -ExpandProperty calling_plans
        
        Write-Output $response        
    }	
}
