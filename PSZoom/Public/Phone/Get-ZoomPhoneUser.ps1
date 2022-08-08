<#

.SYNOPSIS
View specific user Zoom Phone account.

.DESCRIPTION
View specific user Zoom Phone account.

.PARAMETER UserId
The user ID or email address.


.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a user's phone info.
Get-ZoomPhoneUser jsmith@lawfirm.com

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/phoneuser

#>

function Get-ZoomPhoneUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('email', 'emailaddress', 'id', 'user_id', 'ids', 'userids', 'emails', 'emailaddresses')]
        [string[]]$UserId
     )

    process {
        foreach ($id in $UserId) {
            $request = [System.UriBuilder]"https://api.zoom.us/v2/phone/users/$id"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}