<#

.SYNOPSIS
View specific user Zoom Phone profile settings.

.DESCRIPTION
View specific user Zoom Phone profile settings.

.PARAMETER UserId
The user ID or email address.

.OUTPUTS
An object with the Zoom API response.

.EXAMPLE
Retrieve a user's phone info.
Get-ZoomPhoneUserSettings jsmith@lawfirm.com

.LINK
https://developers.zoom.us/docs/api/rest/reference/phone/methods/#operation/phoneUserSettings

#>

function Get-ZoomPhoneUserSettings {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('email', 'emailaddress', 'id', 'user_id', 'ids', 'userids', 'emails', 'emailaddresses', 'host_id')]
        [string[]]$UserId
     )

    process {
        foreach ($id in $UserId) {
            $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users/$id/settings"

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

            Write-Output $response
        }
    }
}