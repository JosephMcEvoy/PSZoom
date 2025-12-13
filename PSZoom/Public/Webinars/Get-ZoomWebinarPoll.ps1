<#

.SYNOPSIS
Get a webinar poll.

.DESCRIPTION
Returns a webinar's poll details.

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER PollId
The poll ID.

.OUTPUTS
PSCustomObject containing the webinar poll details.

.LINK
https://developers.zoom.us/docs/api/webinars/#tag/webinars/GET/webinars/{webinarId}/polls/{pollId}

.EXAMPLE
Get-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123'

Returns the poll details for the specified webinar and poll ID.

.EXAMPLE
Get-ZoomWebinarPoll 123456789 'abc123'

Returns the poll details using positional parameters.

.EXAMPLE
$webinar = Get-ZoomWebinar -WebinarId 123456789
Get-ZoomWebinarPoll -WebinarId $webinar.id -PollId 'poll_xyz'

Gets a specific poll from a webinar object.

#>

function Get-ZoomWebinarPoll {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [int64]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('poll_id')]
        [string]$PollId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/polls/$PollId"

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
