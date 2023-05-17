<#
.SYNOPSIS
End a meeting by updating its status.
.DESCRIPTION
End a meeting by updating its status.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ShareRecording
Determine how the meeting recording is shared.
.PARAMETER RecordingAuthentication
Only authenticated users can view.
.PARAMETER AuthenticationOption
Authentication Options.
.PARAMETER AuthenticationDomains
Authentication domains.
.PARAMETER ViewerDownload
Determine whether a viewer can download the recording file or not.
.PARAMETER Password
Enable password protection for the recording by setting a password. The password must have a minimum of 8 characters, with a mix of numbers, letters and special characters.
.PARAMETER OnDemand
Determine whether registration is required to view the recording.
.PARAMETER ApprovalType
Approval type for the registration. Integer 0 (Auotmatic approval when user registers), 1 (Manual approval of user registration), 2 (No registration required)
.PARAMETER SendEmailToHost
Send an email to host when someone registers to view the recording. This applies for On-Demand recordings only.
.PARAMETER ShowSocialShareButtons
Show social share buttons on registration page. This applies for On-Demand recordings only.
.PARAMETER Topic
Name of the recording.
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/cloud-recording/recordingsettingsupdate
.EXAMPLE
Update-ZoomMeetingRecordingsSettings -MeetingId xxxxxxxx -ShareRecording none
#>

function Update-ZoomMeetingRecordingsSettings {
    [CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact='Medium')]
    param (
        [Parameter(
            Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

        [Parameter(
            HelpMessage = 'Share the recording.',
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('publicly', 'internally', 'none')]
        [Alias('share_recording')]
        [string]$ShareRecording,

        [Parameter(
            HelpMessage = 'Only authenticated users can view.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('recording_authentication')]
        [bool]$RecordingAuthentication,

        [Parameter(
            HelpMessage = 'Authentication Options.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('authentication_option')]
        [string]$AuthenticationOption,

        [Parameter(
            HelpMessage = 'Authentication domains.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('authentication_domains')]
        [string]$AuthenticationDomains,

        [Parameter(
            HelpMessage = 'Whether viewer can download or not.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('viewer_download')]
        [bool]$ViewerDownload,

        [Parameter(
            HelpMessage = 'Enable password protection, must be 8 characters with a mix of numbers, letters and special characters.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('password')]
        [string]$recPassword,

        [Parameter(
            HelpMessage = 'Force registration to view the recording.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('on_demand')]
        [bool]$OnDemand,

        [Parameter(
            HelpMessage = 'Approval type for the registration. 0 - Automatic approval, 1 - Manual approval, 2 - No registration required.',
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('0', '1', '2')]
        [Alias('approval_type')]
        [int]$ApprovalType,

        [Parameter(
            HelpMessage = 'Enable email to host when user registers to view recording. Only available if On-Demand is enabled.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('send_email_to_host')]
        [bool]$SendEmailToHost,

        [Parameter(
            HelpMessage = 'Show social share buttons on the registration page. Only available is On-Demand is enabled.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('show_social_share_buttons')]
        [bool]$ShowSocialShareButtons,

        [Parameter(
            HelpMessage = 'Name of the recording.',
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('topic')]
        [string]$recTopic
    )

    process {
        #Double Encode MeetingId in case UUID needs it.
        $MeetingId = [uri]::EscapeDataString($MeetingId)
        $MeetingId = [uri]::EscapeDataString($MeetingId)

        $request = [System.UriBuilder]"https://api.$ZoomURI/v2/meetings/$MeetingId/recordings/settings"
        $requestBody = @{}

        if ($PSBoundParameters.ContainsKey('ShareRecording')) {
            $requestBody.Add('share_recording', $ShareRecording)
        }

        if ($PSBoundParameters.ContainsKey('RecordingAuthentication')) {
            $requestBody.Add('recording_authentication', $RecordingAuthentication)
        }

        if ($PSBoundParameters.ContainsKey('AuthenticationOption')) {
            $requestBody.Add('authentication_option', $AuthenticationOption)
        }

        if ($PSBoundParameters.ContainsKey('AuthenticationDomains')) {
            $requestBody.Add('authentication_domains', $AuthenticationDomains)
        }

        if ($PSBoundParameters.ContainsKey('ViewerDownload')) {
            $requestBody.Add('viewer_download', $ViewerDownload)
        }

        if ($PSBoundParameters.ContainsKey('recPassword')) {
            $requestBody.Add('password', $recPassword)
        }

        if ($PSBoundParameters.ContainsKey('OnDemand')) {
            $requestBody.Add('on_demand', $OnDemand)
        }

        if ($PSBoundParameters.ContainsKey('ApprovalType')) {
            $requestBody.Add('approval_type', $ApprovalType)
        }

        if ($PSBoundParameters.ContainsKey('SendEmailToHost')) {
            $requestBody.Add('send_email_to_host', $SendEmailToHost)
        }

        if ($PSBoundParameters.ContainsKey('ShowSocialShareButtons')) {
            $requestBody.Add('show_social_share_buttons', $ShowSocialShareButtons)
        }

        if ($PSBoundParameters.ContainsKey('recTopic')) {
            $requestBody.Add('topic', $recTopic)
        }

        $requestBody = ConvertTo-Json $requestBody

        if ($pscmdlet.ShouldProcess) {
            $response = Invoke-ZoomRestMethod -Uri $request.Uri -Body $requestBody -Method PATCH

            Write-Output $response
        }
    }
}