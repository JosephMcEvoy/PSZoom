<#

.SYNOPSIS
Schedule a meeting using the Zoom Rooms Client.

.DESCRIPTION
Schedule a meeting using the Zoom Rooms Client.

.PARAMETER RoomId
The ID of the room that is joining the meeting.

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
New-ZoomRoomMeeting

#>

function New-ZoomRoomMeeting {
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
            Mandatory = $True, 
            ValueFromPipeline = $True, 
            ValueFromPipelineByPropertyName = $True,
            Position = 1
        )]
        [string]$Topic,

        [Parameter(
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidatePattern("[A-Za-z0-9@\-_\*]{1,10}")] #Letters, numbers, '@', '-', '_', '*' from 1 to 10 chars
        [string]$Password,

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
        
        [switch]$JoinBeforeHost,

        [string]$CallbackUrl,

        [string]$JsonRPC = '2.0',

        [string]$Method = 'meetingSchedule',

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
            $request = [System.UriBuilder]"https://api.zoom.us/v2/rooms/$id/meetings"  

            $requestBody = @{
                'jsonrpc' = $JsonRpc
                'method'  = $Method
                'params' = @{
                    'meeting_info' = @{
                        'topic' = $Topic
                        'duration' = $Duration
                        'start_time' = $StartTime
                    }
                }
            }

            if ($PSBoundParameters.ContainsKey('password')) {
                $requestBody.params.add('password', $Password)
            }

            if ($PSBoundParameters.ContainsKey('callbackurl')) {
                $requestBody.add('callback_url', $CallbackUrl)
            }

            if ($PSBoundParameters.ContainsKey('timezone')) {
                $requestBody.params.meeting_info.add('timezone', $TimeZone)
            }

            if ($JoinBeforeHost) {
                $requestBody.params.meeting_info.settings.add('join_before_host', $True)
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