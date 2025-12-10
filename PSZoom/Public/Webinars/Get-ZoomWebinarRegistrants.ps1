<#

.SYNOPSIS
List registrants of a webinar.

.DESCRIPTION
List registrants of a webinar. A host or co-host can require registration for a webinar.

.PARAMETER WebinarId
The webinar ID.

.PARAMETER OccurrenceId
The webinar occurrence ID.

.PARAMETER Status
Registrant status. pending, approved, denied.

.PARAMETER PageSize
Number of records returned per page. Default 30, max 300.

.PARAMETER PageNumber
Page number of the current results.

.PARAMETER NextPageToken
Next page token for pagination.

.EXAMPLE
Get-ZoomWebinarRegistrants -WebinarId 123456789

.EXAMPLE
Get-ZoomWebinarRegistrants -WebinarId 123456789 -Status 'approved' -PageSize 100

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/webinarRegistrants

#>

function Get-ZoomWebinarRegistrants {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('webinar_id', 'id')]
        [string]$WebinarId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('occurrence_id')]
        [string]$OccurrenceId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('pending', 'approved', 'denied')]
        [string]$Status = 'approved',

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('page_number')]
        [int]$PageNumber,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/webinars/$WebinarId/registrants"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $query.Add('status', $Status)
        $query.Add('page_size', $PageSize)

        if ($PSBoundParameters.ContainsKey('OccurrenceId')) {
            $query.Add('occurrence_id', $OccurrenceId)
        }

        if ($PSBoundParameters.ContainsKey('PageNumber')) {
            $query.Add('page_number', $PageNumber)
        }

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $query.ToString()
        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method Get

        Write-Output $response
    }
}
