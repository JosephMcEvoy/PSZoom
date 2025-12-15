<#

.SYNOPSIS
Delete a webinar.

.DESCRIPTION
Delete a webinar.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER OccurrenceId
The webinar occurrence ID.

.PARAMETER CancelWebinarReminder
If true, notify host and panelists about the webinar cancellation via email.

.PARAMETER Passthru
Return the webinar ID if successful.

.EXAMPLE
Remove-ZoomWebinar -WebinarId 123456789

.EXAMPLE
Remove-ZoomWebinar -WebinarId 123456789 -OccurrenceId 'abc123' -CancelWebinarReminder $true

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarDelete

#>

function Remove-ZoomWebinar {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('occurrence_id')]
        [string]$OccurrenceId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('cancel_webinar_reminder')]
        [bool]$CancelWebinarReminder,

        [switch]$Passthru
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId"

        if ($PSBoundParameters.ContainsKey('OccurrenceId') -or $PSBoundParameters.ContainsKey('CancelWebinarReminder')) {
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

            if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
                $query.Add('occurrence_id', $OccurrenceId)
            }

            if ($PSBoundParameters.ContainsKey('CancelWebinarReminder')) {
                $query.Add('cancel_webinar_reminder', $CancelWebinarReminder.ToString().ToLower())
            }

            $Request.Query = $query.ToString()
        }

        if ($PSCmdlet.ShouldProcess($WebinarId, 'Delete webinar')) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Delete

            if ($Passthru) {
                Write-Output $WebinarId
            } else {
                Write-Output $response
            }
        }
    }
}
