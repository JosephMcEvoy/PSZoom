<#

.SYNOPSIS
Retrieve a report containing past webinar participants. 

.DESCRIPTION
Retrieve a report containing past webinar participants

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken 
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.EXAMPLE
Get-ZoomWebinarParticipantsReport 1234567890

.EXAMPLE
Export to CSV the participants from all webinars of a particular name from a given user. Does not take into account webinars with over 300 participants.
$Ids = ((Get-ZoomWebinarsFromUser myoda@thejedi.com -PageSize 300).webinars | where-object topic -eq 'Training').id
$Ids | foreach-object {
    (Get-ZoomWebinarParticipantsReport $_ -PageSize 300).participants
} | Export-Csv techtalkparticipants.csv

.OUTPUTS
A hastable with the Zoom API response.

#>

function Get-ZoomWebinarParticipantsReport {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipelineByPropertyName = $True,
            ParameterSetName = 'Default',
            Position = 0
        )]
        [Alias('id')]
        [string[]]$WebinarId,

        [ValidateRange(1,300)]
        [int]$PageSize = 30,

        [string]$NextPageToken
    )

    process {
        foreach ($id in $WebinarId) {
            $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/report/webinars/$WebinarId/participants"
            $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $query.Add('page_size', $PageSize)

            if ($PSBoundParameters.ContainsKey('NextPageToken')) {
                $Query.add('next_page_token', $NextPageToken)
            }

            $Request.Query = $query.ToString()

            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
            
            Write-Output $response
        }
    }
}