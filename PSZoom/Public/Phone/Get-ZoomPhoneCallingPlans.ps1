<#

.SYNOPSIS
List all Zoom Phone calling plans that are enabled for Account.

.DESCRIPTION
List all Zoom Phone calling plans that are enabled for Account.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/listcallingplans
	
.EXAMPLE
Return the list of all Calling plans.
Get-ZoomPhoneCallingPlans

#>

function Get-ZoomPhoneCallingPlans {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api key/secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }
    process {
        $request = [System.UriBuilder]"https://api.zoom.us/v2/phone/calling_plans"        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
        
        Write-Output $response        
    }	
}
