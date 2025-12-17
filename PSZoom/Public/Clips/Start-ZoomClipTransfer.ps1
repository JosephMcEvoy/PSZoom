<#

.SYNOPSIS
Transfer clips from one user to another.

.DESCRIPTION
Transfer all clips from one user to another. Use this API to initiate the transfer of all Zoom Clips
from one user account to another. This is useful when an employee leaves and their content needs to
be reassigned. The API returns a task ID that can be used to check the transfer status.

Scopes: clip:write, clip:write:admin

.PARAMETER FromUserId
The user ID or email address of the user whose clips will be transferred.

.PARAMETER ToUserId
The user ID or email address of the user who will receive the clips.

.OUTPUTS
System.Object - Returns an object containing the transfer task ID.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/transferClips

.EXAMPLE
Start-ZoomClipTransfer -FromUserId "departing@example.com" -ToUserId "receiving@example.com"

Transfer all clips from one user to another.

.EXAMPLE
Start-ZoomClipTransfer -FromUserId "user1@example.com" -ToUserId "user2@example.com"

Initiate a clip transfer and receive a task ID to monitor progress.

#>

function Start-ZoomClipTransfer {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('from_user_id')]
        [string]$FromUserId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('to_user_id')]
        [string]$ToUserId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips/transfers"

        $requestBody = @{
            from_user_id = $FromUserId
            to_user_id   = $ToUserId
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $requestBody -Method POST

        Write-Output $response
    }
}
