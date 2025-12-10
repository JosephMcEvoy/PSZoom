<#

.SYNOPSIS
List past webinar participants.

.DESCRIPTION
List participants from a past webinar.

.PARAMETER WebinarId
The webinar ID or UUID.

.PARAMETER PageSize
Number of records returned per page.

.PARAMETER NextPageToken
Next page token for pagination.

.EXAMPLE
Get-ZoomPastWebinarParticipants -WebinarId 123456789

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/pastWebinarParticipants

#>

function Get-ZoomPastWebinarParticipants {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id', 'uuid')]
        [string]$WebinarId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/past_webinars/$WebinarId/participants"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('page_size', $PageSize)

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $query.ToString()
        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
