<#

.SYNOPSIS
Retrieve the ID, Room_Name, Calendar_Name, eMail, Account_Type, Status, Device_IP, Camera, Microphone, Speaker, Last_Start_Time, Issues, Health.

.DESCRIPTION
Retrieve the ID, Room_Name, Calendar_Name, eMail, Account_Type, Status, Device_IP, Camera, Microphone, Speaker, Last_Start_Time, Issues, Health.

.PARAMETER PageSize
The number of records returned within a single API call (Min 30 - MAX 300)

.PARAMETER NextPageToken
The next page token is used to paginate through large result sets. A next page token will be returned whenever the set of available results exceeds 
the current page size. The expiration period for this token is 15 minutes.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
{
    "page_count":  1,
    "page_number":  1,
    "page_size":  300,
    "total_records":  2,
    "zoom_rooms":  [
                       {
                           "id":  "iA7Lh0BrR7OFnb3SfcWimQ",
                           "room_name":  "My Zoom Room1",
                           "calendar_name":  "MyZoom.Room1",
                           "email":  "MyZoom.Room1@domain.com",
                           "account_type":  "Office 365",
                           "status":  "Available",
                           "device_ip":  "Computer : 192.168.0.1; Controller : 192.168.0.2",
                           "camera":  "Logitech MeetUp",
                           "microphone":  "回音消除话筒 (Logitech MeetUp Speakerphone)",
                           "speaker":  "回音消除话筒 (Logitech MeetUp Speakerphone)",
                           "last_start_time":  "2020-08-20T04:31:23Z",
                           "issues":  [

                                      ],
                           "health":  "noissue",
                           "location":  "Ground Floor"
                       },
                       {
                           "id":  "yiEmdlgwTpK0DyQBg97GKA",
                           "room_name":  "My Zoom Room1",
                           "calendar_name":  "MyZoom.Room1",
                           "email":  "MyZoom.Room1@domain.com",
                           "account_type":  "Office 365",
                           "status":  "Offline",
                           "device_ip":  "Computer : 192.168.0.1; Controller : 192.168.0.2",
                           "camera":  "BCC950 ConferenceCam",
                           "microphone":  "Freisprechtelefon mit Echoausschaltung (BCC950 ConferenceCam)",
                           "speaker":  "Freisprechtelefon mit Echoausschaltung (BCC950 ConferenceCam)",
                           "last_start_time":  "2020-05-26T14:55:54Z",
                           "issues":  [
                                          "Zoom room is offline"
                                      ],
                           "health":  "critical",
                           "location":  "Ground Floor"
                       }
                    ]
}

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/dashboards/dashboardzoomrooms

.EXAMPLE
Get-DashboardZoomRooms

#>

function Get-DashboardZoomRooms {
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [ValidateRange(1,300)]
        [Alias('page_size')]
        [int]$PageSize = 30,

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
        $request = [System.UriBuilder]"https://api.zoom.us/v2/metrics/zoomrooms"
        $query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        $query.Add('page_size', $PageSize)

        if ($NextPageToken) {
            $query.Add('next_page_token', $NextPageToken)
        }

        $request.Query = $query.ToString()

        try {
            $response = Invoke-RestMethod -Uri $request.Uri -Headers $headers -Method GET
        } catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }

        if ($Full) {
            Write-Output $response
        } else {
            Write-Output $response.zoom_rooms
        }
    }
}