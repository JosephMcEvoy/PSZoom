<#

.SYNOPSIS
Retrieve the ID, Room Name, Device Type, App Version, App Target Version Device System, Status.

.DESCRIPTION
Retrieve the ID, Room Name, Device Type, App Version, App Target Version Device System, Status.

.PARAMETER RoomID
The Unique Identifier of the zoom room. This can be retrived from (List-ZoomRooms).id

.PARAMETER ApiKey
The API Key.

.PARAMETER ApiSecret
The API Secret.

.OUTPUTS
[
    {
        "id":  "3923ZF49-E16E-48C5-8E3D-247406D7F059",
        "room_name":  "My Zoom Room1",
        "device_type":  "Controller",
        "app_version":  "5.1.2 (112.0821)",
        "device_system":  "iPad 13.6.1",
        "status":  "Offline"
    },
    {
        "id":  "o-rZ1K-hTeCpaL7mJN9Ngg-0",
        "room_name":  "My Zoom Room1",
        "device_type":  "Zoom Rooms Computer",      
        "app_version":  "5.1.1 (1624.0806)",        
        "app_target_version":  "5.1.2 (1697.0821)", 
        "device_system":  "Win 10",
        "status":  "Offline"
    }
]

.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/rooms/listzrdevices

.EXAMPLE
Get-ZoomRoomDevices -RoomID 'V5-1Nno-Sf-gtHn_k-GaRw'
#>

function Get-ZoomRoomDevices {
    [CmdletBinding()]
    param (
        # The status of the Zoom Room
        [Parameter(Mandatory = $True)]
        [string]$RoomID,

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
        $request = [System.UriBuilder]"https://api.zoom.us/v2/rooms/$($RoomID)/devices"

        try {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Headers $headers -Method GET -ApiKey $ApiKey -ApiSecret $ApiSecret
        }
        catch {
            Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
        }
        
        Write-Output $response.devices
    }
}

