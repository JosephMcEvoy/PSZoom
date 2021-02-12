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
Array of questions. Requrires three values:
[string]name - Question name
[string]type - Question type
    single - Single choice
    multiple - Multiple choice

Example:
    $Questions = @(
        @('Favorite number?', 'multiple', @('1', '2', '3')), @('Favorite letter?', 'multiple', @('a', 'b', 'c'))
    )
Can also pass New-ZoomMeetingPollQuestion as an array. Example:
$Questions = @(
    (New-ZoomMeetingPollQuestion -Name 'Favorite Number?' -type 'multiple' -answers '1,2,3'), 
    (New-ZoomMeetingPollQuestion -Name 'Favorite letter??' -type 'multiple' -answers 'a,b,c))
)
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
$Questions = @(
    @('Favorite number?', 'multiple', @('1', '2', '3')), @('Favorite letter?', 'multiple', @('a', 'b', 'c'))
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
        [string[]]$Questions,
        
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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/polls"
        $RequestBody = @{}

        if ($PSBoundParameters.ContainsKey('Title')) {
            $RequestBody.Add('title', $Title)
        }        

        
        if ($PSBoundParameters.ContainsKey('Questions')) {
            $RequestBody.Add('questions', $Questions)
        }

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers $headers -Body $RequestBody -Method POST

        Write-Output $response
    }
}

function New-ZoomMeetingPollQuestion {
    param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$Name,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('single', 'multiple')]
        [string]$Type,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias('answer')]
        [string[]]$Answers
    )
    process {
        $Question = @(
            $Name, $Type, $Answers
        )

        return $Question
    }
    
}