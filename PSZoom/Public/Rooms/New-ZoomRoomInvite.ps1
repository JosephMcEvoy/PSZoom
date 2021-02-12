<#

.SYNOPSIS
Invite a contact using the Zoom Rooms Client.

.DESCRIPTION
Invite a contact using the Zoom Rooms Client.

.PARAMETER RoomId
The ID of the room that is joining the meeting.

.PARAMETER callee
Callee's user id or list of callees' user ids, the maximum size of the callee list is 10 items. 
For example ["kYAJ5yMfTCe0npL2_w3agw","jAXKRO6yRZWkdkZxbUuI_Q"]

.PARAMETER JsonRPC
A string specifying the version of the JSON-RPC protocol. Default is 2.0.

.PARAMETER ApiKey
The Api Key.

.PARAMETER ApiSecret
The Api Secret.

.OUTPUTS
JSON object that looks like:
{
  "jsonrpc": "2.0",
  "result": {
    "room_id": "63UtYMhSQZaBRPCNRXrD8A",
    "send_at": "2017-09-15T01:26:05Z"
  },
  "id": "49cf01a4-517e-4a49-b4d6-07237c38b749"
}

.LINK
https://marketplace.zoom.us/docs/guides/zoom-rooms/zoom-rooms-api

.EXAMPLE
Invite a Zoom user to a room's active meeting:
New-ZoomRoomInvite -roomid dEaS6ZJZTOCBKL1oeyc9rA -callee 'abc123456789'

.EXAMPLE
Invite all the skywalkers to a room's active meeting:
New-ZoomRoomInvite -roomid abc -callee (Get-ZoomUsers -AllPages | where-object last_name -like '*skywalker*').id

.EXAMPLE
Send an invite to everyone in the 'DarkSide' group:
New-ZoomRoomInvite -roomid abc -callee (Get-ZoomUsers -AllPages | where-object group -like (Get-ZoomGroups | where-object name -like '*DarkSide*').id).id

#>

function New-ZoomRoomInvite {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('zr_id', 'roomids')]
        [string]$RoomId,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('id')]
        [string[]]$callee,

        [string]$JsonRPC = '2.0',

        [string]$Method = 'restart',

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/rooms/$RoomId/zrclient"  

        $requestBody = @{
            'jsonrpc' = $JsonRpc
            'method'  = $Method
            'callee'  = $callee
        }
        
        $requestBody = ConvertTo-Json $requestBody -Depth 2
        $response = Invoke-ZoomRestMethod -Uri $Request.Uri -Headers $headers -Body $requestBody -Method POST

        Write-Output $response
    }
}
