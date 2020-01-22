<#

.SYNOPSIS
Cancel a meeting using the Zoom Rooms Client.
.DESCRIPTION
Cancel a meeting using the Zoom Rooms Client. 

Note: The Zoom documentation for Zoom Rooms controls is comparatively
loose compared to Zoom's other API documentation. The parameters here are based off of this documentation. The
developer (me) doesn't see a purpose for using any other parameter outside of RoomID and MeetingNumber for this
cmdlet. The other parameters are included anyway, in order to be aligned with Zoom's documentation.
.PARAMETER RoomId
The ID of the room that is joining the meeting.
.PARAMETER MeetingNumber
Cancel specified meeting.
.PARAMETER Topic
Meeting topic. Max of 200 characters.
.PARAMETER Password
Meeting password. Password may only contain the following characters: [a-z A-Z 0-9 @ – _ *]. Max of 10 characters.
.PARAMETER StartTime
Meeting start time in ISO date and time format. A time zone offset is required unless a time zone is explicitly 
specified in timezone. such as "2017-11-25T12:00:00Z" or "2017-11-25T12:00:00″ and timezone="America/Los_Angeles".
.PARAMETER TimeZone
Timezone to format start_time, like "America/Los_Angeles". For this parameter value please refer to the id value in 
our [link missing in Zoom documentation]. It is optional if the "start_time" has a time zone offset.
.PARAMETER Duration
Meeting duration (minutes). Used for scheduled meeting only.
.PARAMETER JoinBeforeHost
Join meeting before host start the meeting. Only used for scheduled or recurring meetings.
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
Remove-ZoomRoomMeeting -RoomId 123456789ABCDE -MeetingNumber 1234567890

#>

function Remove-ZoomRoomMeeting {
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
        [Alias('MeetingNumbers')]
        [string[]]$MeetingNumber,

        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 2
        )]
        [string]$Topic,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$StartTime,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$TimeZone,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [int]$Duration,

        [string]$JsonRPC = '2.0',

        [string]$Method = 'meetingCancel',

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
        foreach ($Number in $MeetingNumber) {
            $Request = [System.UriBuilder]"https://api.zoom.us/v2/rooms/$RoomId/meetings"  

            $RequestBody = @{
                'jsonrpc'        = $JsonRpc
                'method'         = $Method
                'meeting_number' = $Number
                'params'         = @{
                    'meeting_info' = @{
                        'topic'      = $Topic
                        'duration'   = $Duration
                        'start_time' = $StartTime
                    }
                }
            }

            if ($PSBoundParameters.ContainsKey('timezone')) {
                $RequestBody.params.meeting_info.add('timezone', $TimeZone)
            }
            
            $RequestBody = ConvertTo-Json $RequestBody -Depth 2
<#
            try {
                $response = Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Body $RequestBody -Method POST
            } catch {
                Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
            }
#>
            Write-Output $RequestBody
        }
    }
}