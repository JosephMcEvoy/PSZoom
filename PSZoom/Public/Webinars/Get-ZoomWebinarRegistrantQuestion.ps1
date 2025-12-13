<#

.SYNOPSIS
List registration questions for a Zoom webinar.

.DESCRIPTION
List registration questions and fields that are to be answered by users while registering for a webinar.

Scheduling a webinar with registration requires your registrants to complete a brief form with fields and questions before they can receive the link to join the webinar.

Prerequisites:
* Pro or higher plan with the webinar add-on.

.PARAMETER WebinarId
The webinar's ID.

.OUTPUTS
PSCustomObject containing the registration questions and custom questions for the webinar.

.LINK
https://developers.zoom.us/docs/api/rest/reference/webinar/methods/#operation/webinarRegistrantsQuestionsGet

.EXAMPLE
Get-ZoomWebinarRegistrantQuestion -WebinarId 123456789

Returns the registration questions for the specified webinar.

.EXAMPLE
123456789 | Get-ZoomWebinarRegistrantQuestion

Returns the registration questions for the webinar using pipeline input.

.EXAMPLE
Get-ZoomWebinar -UserId 'user@example.com' | Get-ZoomWebinarRegistrantQuestion

Gets all webinars for a user and retrieves registration questions for each.

#>

function Get-ZoomWebinarRegistrantQuestion {
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
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/registrants/questions"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
