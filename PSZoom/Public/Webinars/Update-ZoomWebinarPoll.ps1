<#

.SYNOPSIS
Update a webinar's poll.

.DESCRIPTION
Update a webinar's poll.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER PollId
The poll ID.

.PARAMETER Title
Poll title.

.PARAMETER Questions
Array of poll questions.

.PARAMETER Anonymous
Allow anonymous responses.

.EXAMPLE
Update-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Title 'Updated Poll Title'

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPollUpdate

#>

function Update-ZoomWebinarPoll {
    [CmdletBinding()]
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
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('poll_id')]
        [string]$PollId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Title,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [hashtable[]]$Questions,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Anonymous
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/polls/$PollId"

        $requestBody = @{}

        if ($PSBoundParameters.ContainsKey('Title')) {
            $requestBody['title'] = $Title
        }

        if ($PSBoundParameters.ContainsKey('Questions')) {
            $requestBody['questions'] = $Questions
        }

        if ($PSBoundParameters.ContainsKey('Anonymous')) {
            $requestBody['anonymous'] = $Anonymous
        }

        if ($requestBody.Count -gt 0) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10
            $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Put
            Write-Output $response
        }
    }
}
