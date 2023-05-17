<#

.SYNOPSIS
Retrieve a user’s permissions.

.DESCRIPTION
Retrieve a user’s permissions.

.PARAMETER UserId
The user ID or email address.


.OUTPUTS
A hastable with the Zoom API response.

.EXAMPLE
Get-ZoomUserPermissions jsmith@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userpermission
#>

function Get-ZoomUserPermissions {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string]$UserId
     )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/users/$UserId/permissions"
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        Write-Output $response
    }
}