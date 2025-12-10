<#

.SYNOPSIS
List H.323/SIP devices on an account.

.DESCRIPTION
List H.323/SIP devices on an account.

.PARAMETER PageSize
The number of records returned within a single API call. Default is 30, max is 300.

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets.

.EXAMPLE
Get-ZoomH323Devices

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/deviceList

#>

function Get-ZoomH323Devices {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('page_size')]
        [ValidateRange(1, 300)]
        [int]$PageSize = 30,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken
    )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/h323/devices"
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
