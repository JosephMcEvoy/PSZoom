<#

.SYNOPSIS
Get details of a webinar registrant.

.DESCRIPTION
Zoom users with a webinar plan have access to creating and managing webinars. The webinar feature lets a host broadcast a Zoom meeting to up to 10,000 attendees. Scheduling a webinar with registration requires your registrants to complete a brief form before receiving the link to join the webinar.
Use this API to get details on a specific user who has registered for the webinar.

Prerequisites:
* The account must have a webinar plan.

.PARAMETER WebinarId
The webinar's ID.

.PARAMETER RegistrantId
The registrant ID.

.PARAMETER OccurrenceId
The meeting or webinar occurrence ID.

.OUTPUTS
A hashtable containing the webinar registrant details.

.LINK
https://developers.zoom.us/docs/api/rest/reference/webinar/methods/#operation/webinarRegistrantGet

.EXAMPLE
Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz'

Gets the details of a specific registrant for the webinar.

.EXAMPLE
Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz' -OccurrenceId '1648194360000'

Gets the details of a specific registrant for a particular occurrence of a recurring webinar.

.EXAMPLE
$registrants = Get-ZoomWebinarRegistrants -WebinarId 123456789
$registrants.registrants | ForEach-Object { Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId $_.id }

Gets detailed information for all registrants of a webinar.

#>

function Get-ZoomWebinarRegistrant {
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
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('registrant_id', 'id')]
        [string]$RegistrantId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [Alias('occurrence_id')]
        [string]$OccurrenceId
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/registrants/$RegistrantId"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $query.Add('occurrence_id', $OccurrenceId)
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
