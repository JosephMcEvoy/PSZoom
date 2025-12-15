<#

.SYNOPSIS
Retrieve Q&A from a past webinar.

.DESCRIPTION
Retrieves the Q&A data from a past webinar. This endpoint returns the questions and answers
from webinars that have ended.

Prerequisites:
* Pro or higher plan with the Webinar Add-on.

Scopes: webinar:read:admin, webinar:read
Granular Scopes: webinar:read:list_past_qa, webinar:read:list_past_qa:admin
Rate Limit Label: Medium

.PARAMETER WebinarId
The webinar's ID or universally unique ID (UUID).
If a webinar ID is provided instead of a UUID, the response will be for the latest instance of the webinar.
If a UUID starts with "/" or contains "//", you must double-encode the UUID before making an API request.

.OUTPUTS
An object with the Zoom API response containing the Q&A data.

.EXAMPLE
Get-ZoomPastWebinarQA -WebinarId 123456789

Gets Q&A data for webinar with ID 123456789.

.EXAMPLE
Get-ZoomPastWebinarQA -WebinarId "ABC123xyz=="

Gets Q&A data using a webinar UUID.

.EXAMPLE
123456789 | Get-ZoomPastWebinarQA

Gets Q&A data via pipeline.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listPastWebinarQA

#>

function Get-ZoomPastWebinarQA {
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
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/past_webinars/$WebinarId/qa"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
