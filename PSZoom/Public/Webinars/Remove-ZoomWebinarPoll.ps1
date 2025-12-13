<#

.SYNOPSIS
Delete a webinar's poll.

.DESCRIPTION
Delete a webinar's poll.

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:delete:poll, webinar:delete:poll:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER PollId
The poll ID.

.OUTPUTS
An object with the Zoom API response.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPollDelete

.EXAMPLE
Remove-ZoomWebinarPoll -WebinarId 123456789 -PollId 'qWeRtYuI'

Deletes the specified poll from the webinar.

.EXAMPLE
123456789 | Remove-ZoomWebinarPoll -PollId 'qWeRtYuI'

Deletes the poll using pipeline input for the webinar ID.

.EXAMPLE
Get-ZoomWebinar -WebinarId 123456789 | Remove-ZoomWebinarPoll -PollId 'qWeRtYuI' -Confirm:$false

Deletes the poll without confirmation prompts.

#>

function Remove-ZoomWebinarPoll {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'High')]
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

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", "Delete poll '$PollId'")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method DELETE

            Write-Output $response
        }
    }
}
