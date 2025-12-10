<#

.SYNOPSIS
Create a poll for a webinar.

.DESCRIPTION
Create a poll for a webinar.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER Title
Poll title.

.PARAMETER Questions
Array of poll questions. Each question should be a hashtable with 'name', 'type', and 'answers' keys.

.PARAMETER Anonymous
Allow anonymous responses.

.EXAMPLE
$questions = @(
    @{
        name = 'What is your favorite color?'
        type = 'single'
        answers = @('Red', 'Blue', 'Green')
    }
)
New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Color Poll' -Questions $questions

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarPollCreate

#>

function New-ZoomWebinarPoll {
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
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Title,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [hashtable[]]$Questions,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [bool]$Anonymous
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/webinars/$WebinarId/polls"

        $requestBody = @{
            'title'     = $Title
            'questions' = $Questions
        }

        if ($PSBoundParameters.ContainsKey('Anonymous')) {
            $requestBody['anonymous'] = $Anonymous
        }

        $requestBody = ConvertTo-Json $requestBody -Depth 10
        $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

        Write-Output $response
    }
}
