<#

.SYNOPSIS
List poll results of a past webinar.

.DESCRIPTION
Retrieves the poll results of a past webinar. The list of poll results are returned for the specified
webinar ID.

Prerequisites:
* Pro or higher plan with the Webinar Add-on.

Scopes: webinar:read:admin, webinar:read
Granular Scopes: webinar:read:list_past_polls, webinar:read:list_past_polls:admin
Rate Limit Label: Medium

.PARAMETER WebinarId
The webinar's ID or universally unique ID (UUID).
If a webinar ID is provided instead of a UUID, the response will be for the latest instance of the webinar.
If a UUID starts with "/" or contains "//", you must double-encode the UUID before making an API request.

.OUTPUTS
An object with the Zoom API response containing the poll results.

.EXAMPLE
Get-ZoomPastWebinarPoll -WebinarId 123456789

Gets poll results for webinar with ID 123456789.

.EXAMPLE
Get-ZoomPastWebinarPoll -WebinarId "ABC123xyz=="

Gets poll results using a webinar UUID.

.EXAMPLE
123456789 | Get-ZoomPastWebinarPoll

Gets poll results via pipeline.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listPastWebinarPollResults

#>

function Get-ZoomPastWebinarPoll {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/past_webinars/$WebinarId/polls"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
