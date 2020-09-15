<#

.SYNOPSIS
Restart Zoom Room client.

.DESCRIPTION
Restart Zoom Room client.

.PARAMETER RoomId
The ID of the room that is restarting.

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
Restart-ZoomRoom dEaS6ZJZTOCBKL1oeyc9rA

.EXAMPLE
Restart-ZoomRoom -RoomId dEaS6ZJZTOCBKL1oeyc9rA

.EXAMPLE
Restart all Zoom rooms:
Get-ZoomRooms | Restart-ZoomRoom

#>

function Restart-ZoomRoom {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('zr_id', 'roomids')]
        [string[]]$RoomId,

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
        foreach ($id in $RoomId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/rooms/$id/zrclient"  

            $requestBody = @{
                'jsonrpc' = $JsonRpc
                'method'  = $Method
            }
            
            $requestBody = ConvertTo-Json $requestBody -Depth 2
    
            try {
                $response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $requestBody -Method POST
             } catch {
                 Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
             }
    
            Write-Output $response
        }
    }
}
