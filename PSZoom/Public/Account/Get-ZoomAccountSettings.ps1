<#

.SYNOPSIS
Get the settings of an account.

.DESCRIPTION
Get the settings of an account.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/accounts/accountsettings
	
.EXAMPLE
Return the list of all Calling plans.
Get-ZoomAccountSettings

#>

function Get-ZoomAccountSettings {
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
        $request = [System.UriBuilder]"https://api.zoom.us/v2/accounts/me/settings"        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
        
        Write-Output $response        
    }	
}
