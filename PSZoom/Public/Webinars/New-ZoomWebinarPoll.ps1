<#

.SYNOPSIS
Create a webinar's poll.

.DESCRIPTION
Creates a poll for a webinar.

Prerequisites:
* A Pro or higher plan with a Webinar plan add-on.

Scopes: webinar:write:admin, webinar:write
Granular Scopes: webinar:write:poll, webinar:write:poll:admin
Rate Limit Label: LIGHT

.PARAMETER WebinarId
The webinar's ID.

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
* $false - Do not allow anonymous responses (default).

.PARAMETER PollType
The type of poll:
* 1 - Poll (default)
* 2 - Advanced Poll
* 3 - Quiz

.OUTPUTS
An object with the Zoom API response containing the created poll details.

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPollCreate

.EXAMPLE
$questions = @(
    @{
        name = 'How would you rate this webinar?'
        type = 'single'
        answers = @('Excellent', 'Good', 'Average', 'Poor')
    }
)
New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Feedback Poll' -Questions $questions

Creates a basic poll with a single-choice question.

.EXAMPLE
$questions = @(
    @{
        name = 'Which topics interest you?'
        type = 'multiple'
        answers = @('API Development', 'Security', 'Performance')
        answer_required = $true
    },
    @{
        name = 'Additional comments'
        type = 'long_answer'
    }
)
New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Interest Survey' -Questions $questions -Anonymous $true -PollType 2

Creates an advanced poll with anonymous responses.

.EXAMPLE
Get-ZoomWebinar -WebinarId 123456789 | New-ZoomWebinarPoll -Title 'Quick Poll' -Questions @(@{name='Ready?';type='single';answers=@('Yes','No')})

Creates a poll using pipeline input for the webinar ID.

#>

function New-ZoomWebinarPoll {
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
        [ValidateLength(1, 64)]
        [string]$Title,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [System.Collections.IDictionary[]]$Questions,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Anonymous,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('poll_type')]
        [ValidateSet(1, 2, 3)]
        [int]$PollType
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/polls"

        # Build request body with mandatory parameters
        $RequestBody = @{
            'title'     = $Title
            'questions' = @($Questions)
        }

        # Add optional parameters if specified
        if ($PSBoundParameters.ContainsKey('Anonymous')) {
            $RequestBody.Add('anonymous', $Anonymous)
        }

        if ($PSBoundParameters.ContainsKey('PollType')) {
            $RequestBody.Add('poll_type', $PollType)
        }

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10

        if ($PSCmdlet.ShouldProcess("Webinar '$WebinarId'", "Create poll '$Title'")) {
            $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Body $RequestBody -Method POST

            Write-Output $response
        }
    }
}
