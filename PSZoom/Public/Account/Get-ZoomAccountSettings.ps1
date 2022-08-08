<#

.SYNOPSIS
Get the settings of an account.

.DESCRIPTION
Get the settings of an account.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/accounts/accountsettings
	
.EXAMPLE
Return the list of all Calling plans.
Get-ZoomAccountSettings

#>

function Get-ZoomAccountSettings {
    [CmdletBinding()]
    param ()

    process {
        $request = [System.UriBuilder]"https://api.zoom.us/v2/accounts/me/settings"        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
        
        Write-Output $response        
    }	
}
