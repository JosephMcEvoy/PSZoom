<#

.SYNOPSIS
Join a meeting from the Zoom Rooms Client if the meeting number is available. Start an instant meeting if the 
meeting number is empty.
.DESCRIPTION
Join a meeting from the Zoom Rooms Client if the meeting number is available. Start an instant meeting if the 
meeting number is empty.
.PARAMETER RoomId
The ID of the room that is joining the meeting.
.PARAMETER MeetingNumber
Start an instant meeting if meeting number is empty, otherwise join specified meeting.
.PARAMETER Password
Meeting password. Password may only contain the following characters: [a-z A-Z 0-9 @ – _ *]. Max of 10 characters.
.Parameter Force
The default value is false and current user is in a meeting, the client will ignore the request. Join the meeting 
immediately if current user is not in any meeting.  The value is true means the user will be forced to leave 
current meeting and join the meeting immediately.
.PARAMETER CallbackUrl
Create a post request with json payload once Zoom Rooms client sends request with corresponding response. 
For an example: CallbackUrl looks like this "https://api.test.zoom.us/callback?token=test123", 
Context-Type is "application/json" payload is {"request_id": 123, "meeting_number":"1234567890″}
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
Connect-ZoomRoomMeeting dEaS6ZJZTOCBKL1oeyc9rA 123456789 password12
.EXAMPLE
Connect-ZoomRoomMeeting -RoomId dEaS6ZJZTOCBKL1oeyc9rA -MeetingId 1234567890 -Password password12 -Force

#>

function Connect-ZoomRoomMeeting {
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

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [Alias('meeting_number', 'meeting')]
        [string]$MeetingNumber = '',

        [Parameter(
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [ValidatePattern("[A-Za-z0-9@\-_\*]{1,10}")] #Letters, numbers, '@', '-', '_', '*' from 1 to 10 chars
        [string]$Password,

        [switch]$Force = $False,

        [string]$CallbackUrl,

        [string]$JsonRPC = '2.0',

        [string]$Method = 'join',

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        foreach ($Id in $RoomId) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/rooms/$Id/meetings"  

            $RequestBody = @{
                'jsonrpc' = $JsonRpc
                'method'  = $Method
                'params' = @{
                    'meeting_number' = $MeetingNumber
                }
            }

            if ($PSBoundParameters.ContainsKey('password')) {
                $RequestBody.params.add('password', $Password)
            }

            if ($PSBoundParameters.ContainsKey('CallbackUrl')) {
                $RequestBody.add('callback_url', $CallbackUrl)
            }

            if ($Force) {
                $RequestBody.add('force_Accept', $True)
            } else {
                $RequestBody.params.add('force_accept', $False)
            }
            
            $RequestBody = ConvertTo-Json $RequestBody -Depth 2

            try {
                $response = Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Body $RequestBody -Method POST
            } catch {
                Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
            }

            Write-Output $response
        }
    }
}