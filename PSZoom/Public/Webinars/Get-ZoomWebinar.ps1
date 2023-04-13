<#

.SYNOPSIS
Retrieve the details of a webinar.

.DESCRIPTION
Retrieve the details of a webinar.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER OcurrenceId
The Occurrence ID.

.PARAMETER ShowPreviousOccurrences
Set the value of this field to `true` if you would like to view Webinar details of all previous occurrences of a 
recurring Webinar.

.OUTPUTS

.LINK

.EXAMPLE
Get-ZoomWebinar 1234567890

.EXAMPLE
Get the host of a Zoom webinar.
Get-ZoomWebinar 1234567890 | Select-Object host_id | Get-ZoomUser

#>

function Get-ZoomWebinar {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id')]
        [int64]$WebinarId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position=1
        )]
        [Alias('ocurrence_id')]
        [string]$OccurrenceId,

        [ALias('show_previous_occurences')]
        [bool]$ShowPreviousOccurences
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$webinarId"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $Query.add('OccurrenceId', $OccurrenceId)
        }

        if ($PSBoundParameters.ContainsKey('show_previous_occurrences')) {
            $Query.add('show_previous_occurrences', $ShowPreviousOccurrences)
        }      

        $Request.Query = $query.toString()
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $RequestBody -Method GET

        Write-Output $response
    }
}