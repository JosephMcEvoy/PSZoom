<#

.SYNOPSIS
List all Zoom Phone calling plans that are enabled for Account.

.DESCRIPTION
List all Zoom Phone calling plans that are enabled for Account.


.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/listcallingplans
	
.EXAMPLE
Return the list of all Calling plans.
Get-ZoomPhoneCallingPlans
#>

function Get-ZoomPhoneCallingPlans {
    [CmdletBinding()]
    param ()

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/calling_plans"        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
        
        Write-Output $response        
    }	
}
