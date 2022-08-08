<#

.SYNOPSIS
List registration questions that will be displayed to users while registering for a meeeting.
.DESCRIPTION
List registration questions that will be displayed to users while registering for a meeeting.
.PARAMETER MeetingId
The meeting ID.

.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomRegistrationQuestions 123456789

#>

function Get-ZoomRegistrationQuestions {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId
     )

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/registrants/questions"
    
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET
        
        Write-Output $response
    }
}