<#

.SYNOPSIS
List users on a Zoom account who have been assigned Zoom Phone licenses.

.DESCRIPTION
List users on a Zoom account who have been assigned Zoom Phone licenses. 

.PARAMETER SiteId
Unique Identifier of the site. This can be found in the ListPhoneSites API.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 100).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, receive the full JSON Response to see the next_page_token.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone/listphoneusers

.EXAMPLE
Return the first page of Zoom phone users.
Get-ZoomPhoneUsers

.EXAMPLE
Return the first page of Zoom phone users in Site. To find Site ID refer to Get-ZoomPhoneSites
Get-ZoomPhoneUsers ######

.EXAMPLE
Return Zoom phone sites including the next_page_tokens.
Get-ZoomPhoneUsers -SiteId ###### -Full

#>

function Get-ZoomPhoneUsers {
    [CmdletBinding()]
    param (

        [Parameter(
            Mandatory = $False, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('site_id')]
        [int]$SiteId,
		
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [switch]$Full = $False,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [Alias('next_page_token')]
        [string]$NextPageToken
     )

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/phone/users"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('page_size', $PageSize)
        $query.Add('next_page_token', $NextPageToken)

        if ($PSBoundParameters.ContainsKey('SiteId')) {
            $query.Add('site_id', $SiteId)
        }
        
        $request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        if ($Full) {
            Write-Output $response
        } else {
            Write-Output $response.Users
        }
    }
}
