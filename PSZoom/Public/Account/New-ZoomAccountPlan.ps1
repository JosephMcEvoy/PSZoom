<#

.SYNOPSIS
Subscribe a sub account to a plan.

.DESCRIPTION
Subscribe a sub account to a Zoom plan using your master account.

.PARAMETER AccountId
The account ID.

.PARAMETER Contact
Contact information for the account.

.PARAMETER PlanBase
Base plan information. Should contain 'type' and 'hosts' properties.

.PARAMETER PlanZoomRooms
Zoom Rooms plan information.

.PARAMETER PlanRoomConnector
Room Connector plan information.

.PARAMETER PlanLargeMeeting
Large meeting plan information.

.PARAMETER PlanWebinar
Webinar plan information.

.PARAMETER PlanZoomEvents
Zoom Events plan information.

.PARAMETER PlanRecording
Recording plan information.

.PARAMETER PlanAudioConferencing
Audio conferencing plan information.

.PARAMETER PlanPhone
Phone plan information.

.EXAMPLE
New-ZoomAccountPlan -AccountId 'abc123' -PlanBase @{ type = 'pro'; hosts = 10 }

.LINK
https://developers.zoom.us/docs/api/rest/reference/zoom-api/methods/#operation/accountPlanCreate

#>

function New-ZoomAccountPlan {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'account_id')]
        [string]$AccountId,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [hashtable]$Contact,

        [Parameter(
            Mandatory = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('plan_base')]
        [hashtable]$PlanBase,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('plan_zoom_rooms')]
        [hashtable]$PlanZoomRooms,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('plan_room_connector')]
        [hashtable]$PlanRoomConnector,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('plan_large_meeting')]
        [array]$PlanLargeMeeting,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('plan_webinar')]
        [array]$PlanWebinar,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('plan_zoom_events')]
        [array]$PlanZoomEvents,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('plan_recording')]
        [string]$PlanRecording,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('plan_audio')]
        [hashtable]$PlanAudioConferencing,

        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('plan_phone')]
        [hashtable]$PlanPhone
    )

    process {
        $Uri = "https://api.$ZoomURI/v2/accounts/$AccountId/plans"

        $requestBody = @{
            'plan_base' = $PlanBase
        }

        $optionalParams = @{
            'contact'              = 'Contact'
            'plan_zoom_rooms'      = 'PlanZoomRooms'
            'plan_room_connector'  = 'PlanRoomConnector'
            'plan_large_meeting'   = 'PlanLargeMeeting'
            'plan_webinar'         = 'PlanWebinar'
            'plan_zoom_events'     = 'PlanZoomEvents'
            'plan_recording'       = 'PlanRecording'
            'plan_audio'           = 'PlanAudioConferencing'
            'plan_phone'           = 'PlanPhone'
        }

        foreach ($key in $optionalParams.Keys) {
            $paramName = $optionalParams[$key]
            if ($PSBoundParameters.ContainsKey($paramName)) {
                $requestBody[$key] = (Get-Variable $paramName).Value
            }
        }

        if ($PSCmdlet.ShouldProcess($AccountId, "Create Account Plan")) {
            $requestBody = ConvertTo-Json $requestBody -Depth 10
            $response = Invoke-ZoomRestMethod -Uri $Uri -Body $requestBody -Method Post

            Write-Output $response
        }
    }
}
