<#

.SYNOPSIS
Update a webinar's poll.

.DESCRIPTION
Update a webinar's poll.

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:update:poll, webinar:update:poll:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER PollId
The poll ID.

.PARAMETER Title
The poll's title. Maximum length is 64 characters.

.PARAMETER Questions
An array of question hashtables. Each hashtable should contain:
- name: The question text (required)
- type: The question type - 'single', 'multiple', 'short_answer', 'long_answer', 'fill_in_the_blank', 'rating_scale', 'rating_max_scale', or 'matching' (required)
- answers: An array of answer options (required for single/multiple choice)
- right_answers: An array of correct answers (for quiz polls)
- answer_required: Whether the question requires an answer

.PARAMETER Anonymous
Whether to allow anonymous responses:
* $true - Allow participants to answer poll questions anonymously.
* $false - Do not allow anonymous responses.

.PARAMETER PollType
The type of poll:
* 1 - Poll
* 2 - Advanced Poll
* 3 - Quiz

.OUTPUTS
An object with the Zoom API response.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPollUpdate

.EXAMPLE
$questions = @(
    @{
        name = 'How would you rate this session?'
        type = 'single'
        answers = @('Excellent', 'Good', 'Fair', 'Poor')
    }
)
Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'qWeRtYuI' -Title 'Updated Feedback' -Questions $questions

Updates the poll with new questions.

.EXAMPLE
Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'qWeRtYuI' -Anonymous $true

Updates the poll to allow anonymous responses.

.EXAMPLE
123456789 | Set-ZoomWebinarPoll -PollId 'qWeRtYuI' -Title 'New Title'

Updates the poll title using pipeline input.

#>

function Set-ZoomWebinarPoll {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = 'Low')]
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
        [string]$PollId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateLength(1, 64)]
        [string]$Title,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [System.Collections.IDictionary[]]$Questions,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Anonymous,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('poll_type')]
        [ValidateSet(1, 2, 3)]
        [int]$PollType
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/polls/$PollId"

        # Build request body with only provided parameters
        $RequestBody = @{}

        if ($PSBoundParameters.ContainsKey('Title')) {
            $RequestBody.Add('title', $Title)
        }

        if ($PSBoundParameters.ContainsKey('Questions')) {
            $RequestBody.Add('questions', @($Questions))
        }

        if ($PSBoundParameters.ContainsKey('Anonymous')) {
            $RequestBody.Add('anonymous', $Anonymous)
        }

        if ($PSBoundParameters.ContainsKey('PollType')) {
            $RequestBody.Add('poll_type', $PollType)
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("Webinar $WebinarId", "Update poll '$PollId'")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method PUT

            Write-Output $response
        }
    }
}
