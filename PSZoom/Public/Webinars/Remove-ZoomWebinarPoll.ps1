<#

.SYNOPSIS
Delete a webinar's poll.

.DESCRIPTION
Delete a webinar's poll.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER PollId
The poll ID.

.EXAMPLE
Remove-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPollDelete

#>

function Remove-ZoomWebinarPoll {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('poll_id')]
        [string]$PollId
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/polls/$PollId"

        if ($PSCmdlet.ShouldProcess($PollId, "Delete poll from webinar $WebinarId")) {
            $response = Invoke-ZoomRestMethod -Uri $Uri -Method Delete
            Write-Output $response
        }
    }
}
