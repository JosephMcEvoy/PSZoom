<#

.SYNOPSIS
Creates a new Zoom meeting poll.
.DESCRIPTION
Creates a new Zoom meeting poll. Meeting must be a scheduled meeting. 
Instant meetings do not have polling features enabled.
.PARAMETER MeetingId
The meeting ID.
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

.EXAMPLE
$Questions = @(
    @{name = 'Favorite number?'; type = 'multiple'; answers = @('1', '2', '3')},
    @{name = 'Favorite letter?'; type = 'multiple'; answers = @('a', 'b', 'c')}
)

New-ZoomMeetingPoll 123456789 -Title 'Favorite numbers and letters' -Questions $Questions

#>

function New-ZoomMeetingPoll {
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

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [string]$Title,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [System.Collections.IDictionary[]]$Questions
    )

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/polls"
        $RequestBody = @{}

        if ($PSBoundParameters.ContainsKey('Title')) {
            $RequestBody.Add('title', $Title)
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

        $RequestBody = $RequestBody | ConvertTo-Json -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method POST

        Write-Output $response
    }
}
