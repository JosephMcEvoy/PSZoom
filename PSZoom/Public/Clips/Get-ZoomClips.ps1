<#

.SYNOPSIS
List all clips for the current user.

.DESCRIPTION
List all clips for the current user. Use this API to list all Zoom Clips that belong to a user.
Zoom Clips is a video engagement tool that allows you to create short-form video messages for
personal and business communications.

Scopes: clip:read, clip:read:admin

.PARAMETER PageSize
The number of records returned within a single API call.

.PARAMETER NextPageToken
Use the next page token to paginate through large result sets. A next page token is returned whenever
the set of available results exceeds the current page size. This token's expiration period is 15 minutes.

.OUTPUTS
System.Object

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/listClips

.EXAMPLE
Get-ZoomClips

List all clips with default parameters.

.EXAMPLE
Get-ZoomClips -PageSize 50

List clips with a custom page size.

.EXAMPLE
Get-ZoomClips -NextPageToken "abc123"

Get the next page of clips using a pagination token.

#>

function Get-ZoomClips {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('page_size')]
        [ValidateRange(1, 300)]
        [int]$PageSize,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/clips"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('PageSize')) {
            $query.Add('page_size', $PageSize)
        }

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $query.Add('next_page_token', $NextPageToken)
        }

        if ($query.ToString()) {
            $Request.Query = $query.ToString()
        }

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Method GET

        Write-Output $response
    }
}
