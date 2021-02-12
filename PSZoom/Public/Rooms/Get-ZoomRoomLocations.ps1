<#

.SYNOPSIS
Retrieve all location ids or filter on Parent Location ID.

.DESCRIPTION
Retrieve all location ids or filter on Parent Location ID.

.PARAMETER ParentLocationId
A unique identifier for the parent location. For instance, if a Zoom Room is located in Floor 1 of Building A, 
the location of Building A will be the parent location of Floor 1. Use this parameter to filter the response 
by a specific location hierarchy level.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 300).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the
set of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER ApiKey
The API Key.

.PARAMETER ApiSecret
The API Secret.

.OUTPUTS
When using -Full switch, receives JSON Response that looks like:
    page_size next_page_token locations
--------- --------------- ---------
      300                 {@{id=hSCAvg9rR3j42iuMjMddzw..}

When not using -Full, id, name, parent_location_id, type will be returned:
   id                     name      parent_location_id     type
--                     ----      ------------------     ----
AhH8cXHQSxs0ehdPyZbJLQ Coglin St KSq88chVTeS4cSCLtrt8fA campus
WU5haagyThudC9HGfeJo3g London    FGLxfHIKSlmfM_AFdHoGpg city
hSCAvg9rR3m42iuMjMbdzw Australia ltlBo0a8TnWuTkgJG8gV3g country
pMwBGgUfTvKXwj16wXVJ4w Level 11  eKeAS1geQhyKJvnYi-Khww floor
DgaiM8z6ReCOWNFCYoqd1Q Oxford    03Do9TN_T1CrOD_FURePsg state

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/rooms-location/listzrlocations

.EXAMPLE
Get-ZoomRoomLocations
Get-ZoomRoomLocations -ParentLocationId "_AFlXw-FTwGS7BrO1QupVA"

#>

function Get-ZoomRoomLocations {
    [CmdletBinding()]
   param (
        [Parameter(Mandatory = $false)]
        [STRING]$ParentLocationId,

        #The number of records returned within a single API call (Zoom default = 30)
        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 2
        )]
        [ValidateRange(30, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        # The next page token is used to paginate through large result sets. A next page token will be returned 
        # whenever the set of available results exceeds the current page size. The expiration period for this token 
        # is 15 minutes.
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [switch]$Full = $False,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    ) 

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/rooms/locations"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('page_size', $PageSize)

        if ($ParentLocationId) {
            $query.Add('parent_location_id', $ParentLocationId)
        }

        if ($NextPageToken) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $query.ToString()

        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Headers $headers -Method GET

        if ($Full) {
            Write-Output $response
        }
        else {
            Write-Output $response.locations
        }
        
    }
}
