<#

.SYNOPSIS
List sub accounts.

.DESCRIPTION
List sub accounts. You can only call this API if you have the approved partners permission to use a Master API.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/accounts/accounts
	
.EXAMPLE
Return the list of all Calling plans.
Get-ZoomAccounts

#>

function Get-ZoomAccounts {
    [CmdletBinding()]
    param (
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [Alias('next_page_token')]
        [string]$NextPageToken
     )

    process {
        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/accounts"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('page_size', $PageSize)
	
        if ($NextPageToken) {
            $query.Add('next_page_token', $NextPageToken)
        }
	
        $request.Query = $query.ToString()
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET
        
        Write-Output $response        
    }	
}
