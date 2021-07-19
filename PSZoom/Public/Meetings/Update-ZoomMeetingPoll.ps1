<#

.SYNOPSIS
Updates a Zoom meeting poll.
.DESCRIPTION
Updates a Zoom meeting poll.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER PollId
The poll ID.
.PARAMETER Title
Poll title.
.PARAMETER Questions
Array of questions. All elements should be HashTable.
Requires three keys:
[string]name - Question name
[string]type - Question type
    single - Single choice
    multiple - Multiple choice
[string[]]answers - Answers of the question

Example:
    $Questions = @(
        @{name = 'Favorite number?'; type = 'multiple'; answers = @('1', '2', '3')},
        @{name = 'Favorite letter?'; type = 'multiple'; answers = @('a', 'b', 'c')}
    )
Can also pass New-ZoomMeetingPollQuestion as an array. Example:
$Questions = @(
    (New-ZoomMeetingPollQuestion -Name 'Favorite Number?' -type 'multiple' -answers '1','2','3'), 
    (New-ZoomMeetingPollQuestion -Name 'Favorite letter??' -type 'multiple' -answers 'a','b','c')
)
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
$Questions = @(
    (New-ZoomMeetingPollQuestion -Name 'Favorite Number?' -type 'multiple' -answers '1','2','3'), 
    (New-ZoomMeetingPollQuestion -Name 'Favorite letter??' -type 'multiple' -answers 'a','b','c')
)

Update-ZoomMeetingPoll 123456789 -PollId zKbEaqMKeU3soLJ7noFBR8 -Title 'Favorite numbers and letters' -Questions $Questions


#>

function Update-ZoomMeetingPoll {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('poll_id')]
        [string]$PollId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Title,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [System.Collections.IDictionary[]]$Questions,
        
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/polls/$PollId"
        $requestBody = @{}

        if ($PSBoundParameters.ContainsKey('Title')) {
            $requestBody.Add('title', $Title)
        }        
        
        if ($PSBoundParameters.ContainsKey('Questions')) {
            $Items = @($Questions.ForEach( {
                        @{
                            name    = [string]$_.name
                            type    = ([string]$_.type).ToLower() # "single" or "multiple"
                            answers = [string[]]@($_.answers)
                        }
                    }))
            $RequestBody.Add('questions', $Items)
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10 #Uses -Depth because the questions.answers array is flattened without it.

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Body $requestBody -Method PUT -ApiKey $ApiKey -ApiSecret $ApiSecret

        Write-Output $response
    }
}
