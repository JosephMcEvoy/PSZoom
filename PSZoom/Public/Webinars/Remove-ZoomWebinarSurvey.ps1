<#

.SYNOPSIS
Delete a webinar's survey.

.DESCRIPTION
Delete a webinar's survey. Use this API to delete a webinar survey.

Prerequisites:
* A Pro or a higher plan with a Webinar plan add-on.
* The Webinar Survey feature must be enabled in the host's account.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:delete:survey, webinar:delete:survey:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.OUTPUTS
An object with the Zoom API response.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarSurveyDelete

.EXAMPLE
Remove-ZoomWebinarSurvey -WebinarId 123456789

Deletes the survey for the specified webinar.

.EXAMPLE
123456789 | Remove-ZoomWebinarSurvey

Deletes the survey using pipeline input.

.EXAMPLE
Get-ZoomWebinar -UserId 'user@example.com' | Remove-ZoomWebinarSurvey

Deletes surveys for webinars retrieved from Get-ZoomWebinar.

#>

function Remove-ZoomWebinarSurvey {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'Id')]
        [int64]$WebinarId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/survey"

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", 'Delete survey')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE

            Write-Output $response
        }
    }
}
