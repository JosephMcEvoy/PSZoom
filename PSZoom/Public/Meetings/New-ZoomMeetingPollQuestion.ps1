<#

.SYNOPSIS
Creates a Zoom meeting poll question object.
.DESCRIPTION
Creates a Zoom meeting poll question object.
It can be used as input for the Questions parameter of New-ZoomMeetingPoll.
.PARAMETER Name
The name of the question.
.PARAMETER Type
Question type. Should be "single" or "multiple".
.PARAMETER Answers
Answers to the questions.
.EXAMPLE
$Questions = @(
    (New-ZoomMeetingPollQuestion -Name 'Favorite Number?' -type 'multiple' -answers '1','2','3'), 
    (New-ZoomMeetingPollQuestion -Name 'Favorite letter??' -type 'multiple' -answers 'a','b','c')
)

New-ZoomMeetingPoll 123456789 -Title 'Favorite numbers and letters' -Questions $Questions


#>
function New-ZoomMeetingPollQuestion {
    [OutputType([Hashtable])]
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
        $Question = @{
            name    = $Name
            type    = $Type
            answers = $Answers
        }

        Write-Output $Question
    }
}
