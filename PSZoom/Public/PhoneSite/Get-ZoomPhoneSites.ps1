<#

.SYNOPSIS
List all the sites that have been created for an account.

.DESCRIPTION
Sites allow you to organize Zoom Phone users in your organization. Use this API to list all the  that have been created for an account.
Because of this, API calls require a page number (default is 1) and page size (default is 30). 

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 300).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER Full
When using -Full switch, receive the full JSON Response to see the next_page_token.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/phone-site/listphonesites

.OUTPUTS
When using -Full switch, receives JSON Response that looks like:
    {
    "page_size":  30,
    "next_page_token":  "Nz4oT3zfKtl5Ya6shico68mjiKWklN6qmU2",
    "rooms":  [
                  etc..
              ]
    }

When not using -Full, a JSON response that looks like:
    [
        {
            "id":  "bo5ZalTCRZ6dsutGR4SF2A",
            "name":  "Main Site",     
            "level":  "main",
            etc..
        },
        {
            "id":  etc.
        }
    ]
	
.EXAMPLE
Return the first page of active Zoom phone sites.
Get-ZoomPhoneSites

.EXAMPLE
Return all Zoom phone sites with next page tokens.
Get-ZoomPhoneSites -Full

#>

function Get-ZoomPhoneSites {
    [CmdletBinding()]
    param (
        [ValidateRange(1, 100)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        [switch]$Full = $False,
		
        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Header with JWT (JSON Web Token) using the Api key/secret
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }
    process {
        $request = [System.UriBuilder]"https://api.zoom.us/v2/phone/sites"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('page_size', $PageSize)
        if ($NextPageToken) {
            $query.Add('next_page_token', $NextPageToken)
        }
        $request.Query = $query.ToString()
        
        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers ([ref]$Headers) -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret

        if ($Full) {
            Write-Output $response
        } else {
            Write-Output $response.Sites
        }
        
    }	
}