<#

.SYNOPSIS
Get a webinar's survey.

.DESCRIPTION
Retrieves a webinar's survey. Returns the survey questions and settings for the specified webinar.

Prerequisites:
* Pro or higher plan with the Webinar Add-on.

Scopes: webinar:read:admin, webinar:read
Granular Scopes: webinar:read:survey, webinar:read:survey:admin
Rate Limit Label: Light

.PARAMETER WebinarId
The webinar's ID.

.OUTPUTS
An object with the Zoom API response containing the webinar survey.

.EXAMPLE
Get-ZoomWebinarSurvey -WebinarId 123456789

Gets the survey for webinar with ID 123456789.

.EXAMPLE
123456789 | Get-ZoomWebinarSurvey

Gets the survey via pipeline.

.EXAMPLE
Get-ZoomWebinar -WebinarId 123456789 | Get-ZoomWebinarSurvey

Gets the survey by piping from another cmdlet.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarSurveyGet

#>

function Get-ZoomWebinarSurvey {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [int64]$WebinarId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/survey"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
