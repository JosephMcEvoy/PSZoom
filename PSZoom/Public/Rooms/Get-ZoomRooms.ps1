<#

.SYNOPSIS
Retrieves the ID, Room_ID, Name, Location_ID, Status.

.DESCRIPTION
Retrieves the ID, Room_ID, Name, Location_ID, Status.

.PARAMETER Status
The status of the Zoom Room ["Offline", "Avalible", "InMeeting", "UnderConstruction"]

.PARAMETER Type
Type of Zoom Rooms ["ZoomRoom", "SchedulingDisplayOnly", "DigitalSignageOnly"]

.PARAMETER UnassignedRooms
Use this query parameter with a value of $true if you would like to see Zoom Rooms in your account that have not 
been assigned to anyone yet.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 300).

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set 
of available results exceeds the current page size. The expiration period for this token is 15 minutes.

.PARAMETER LocationID
Parent location ID of the Zoom Room

.OUTPUTS
When using -Full switch, receives JSON Response that looks like:
    {
    "page_size":  30,
    "next_page_token":  "Nz4oT3zfKtl5Ya6shico68mjiKWklN6qmU2",
    "rooms":  [
                  {
                      "id":  "bo5ZalTCRZ6dsutGR4SF2A",        
                      "room_id":  "8Fudh-eORuCPpWNk5G7tHg",   
                      "name":  "My Zoom Room1",
                      "location_id":  "0Dwnr3pfRbFPDVZSulvUuQ",      
                      "status":  "Available"
                  },
                  {
                      "id":  "GT7dHGEGSve3_To2rGJ8yB",
                      "room_id":  "VAOjXdS_Q7pZ3btqTMGNSA",
                      "name":  "My Zoom Room2",  
                      "location_id":  "uOHlx4lwR34sQ4Uxft-Nhg",      
                      "status":  "Available"
                  }
              ]
    }

When not using -Full, a JSON response that looks like:
    [
        {
            "id":  "bo5ZalTCRZ6dsutGR4SF2A",
            "room_id":  "8Fudh-eORuCPpWNk5G7tHg",    
            "name":  "My Zoom Room1",     
            "location_id":  "0Dwnr3pfRbFPDVZSulvUuQ",
            "status":  "Available"
        },
        {
            "id":  "GT7dHGEGSve3_To2rGJ8yB",
            "room_id":  "VAOjXdS_Q7pZ3btqTMGNSA",
            "name":  "My Zoom Room2",  
            "location_id":  "uOHlx4lwR34sQ4Uxft-Nhg",      
            "status":  "Available"
        }
    ]

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/rooms/listzoomrooms

.EXAMPLE
List-ZoomRooms

#>

function Get-ZoomRooms {
    [CmdletBinding()]
    param (
        # The status of the Zoom Room
        [Parameter(Mandatory = $False)]
        [ValidateSet("Offline", "Avalible", "InMeeting", "UnderConstruction")]
        [string]$Status,

        # Type of Zoom Rooms
        [Parameter(Mandatory = $False)]
        [ValidateSet("ZoomRoom", "SchedulingDisplayOnly", "DigitalSignageOnly")]
        [string]$Type,

        # Use this query parameter with a value of $true if you would like to see Zoom Rooms in your account that have not been assigned to anyone yet.
        [Alias('unassigned_rooms')]
        [Bool]$UnassignedRooms = $False,

        #The number of records returned within a single API call (Zoom default = 30)
        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position = 2
        )]
        [ValidateRange(30, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

        # The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds the current page size. The expiration period for this token is 15 minutes.
        [Alias('next_page_token')]
        [string]$NextPageToken,

        # Parent location ID of the Zoom Room
        [Alias('location_id')]
        [string]$LocationId,

        [switch]$Full = $False
     )

    process {
        $Request = [System.UriBuilder]"https://api.$ZoomURI/v2/rooms"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('page_size', $PageSize)
        $query.Add('unassigned_rooms', $unassigned_rooms)
        if ($status) {
            $query.Add('status', $status)
        }
        if ($type) {
            $query.Add('type', $type)
        }
        if ($NextPageToken) {
            $query.Add('next_page_token', $NextPageToken)
        }
        if ($LocationId) {
            $query.Add('location_id', $LocationId)
        }
        $Request.Query = $query.ToString()
        

        $response = Invoke-ZoomRestMethod -Uri $request.Uri -Method GET

        if ($Full) {
            Write-Output $response
        }
        else {
            Write-Output $response.rooms
        }
        
    }
}
