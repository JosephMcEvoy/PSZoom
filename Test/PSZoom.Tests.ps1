$TestUri = 'TestUri'
$TestToken = 'TestToken'
$TestArchive = 'TestArchive'
$TestProxy = 'TestProxy'


$PSVersion = $PSVersionTable.PSVersion.Major
$ModuleName = $ENV:BHProjectName
$ModulePath = Join-Path $ENV:BHProjectPath $ModuleName


#Using these variables for local testing
#$PSVersion = $PSVersionTable.PSVersion.Major
#$ModuleName = 'PSZoom'
#$ModulePath = "d:\dev\$ModuleName\$ModuleName"


# Verbose output for non-master builds on appveyor
# Handy for troubleshooting.
# Splat @Verbose against commands as needed (here or in pester tests)

$Verbose = @{}
if($ENV:BHBranchName -notlike "master" -or $env:BHCommitMessage -match "!verbose") {
    $Verbose.add("Verbose", $True)
}

Import-Module $ModulePath -Force

#Import private functions
$Private = @(Get-ChildItem -Path "$ModulePath\Private\" -include '*.ps1' -recurse -ErrorAction SilentlyContinue)

foreach ($file in $Private) {
    try {
        . $file.fullname
    } catch {
        Write-Error -Message "Failed to import function $($ps1.fullname): $_"
    }
}

$Module = Get-Module $ModuleName
$Commands = $Module.ExportedCommands.Keys

function ShowMockInfo($functionName, [String[]] $params) {
    if ($ShowMockData){
        Write-Host " Mocked $functionName" -ForegroundColor Cyan
        foreach ($p in $params) {
            Write-Host " [$p] $(Get-Variable -Name $p -ValueOnly)" -ForegroundColor Cyan
        }
    }
}

Mock -ModuleName $ModuleName Invoke-RestMethod {
    $Response = @{
        Body = $Body
        Uri = $Uri
        Method = $Method
        Headers = $Headers
    }

    Write-Output $Response
}
#Additional variables to use when testing
$UserEmail = 'TestEmail@Test.com'
$UserId = 'aBc'
$GroupId = 'dEf'

Describe "PSZoom General Tests" {
    It 'Should be the correct name' {
        $Module.Name | Should Be $ModuleName
    }

    It 'Should generate a JWT correctly' {
        $token = (New-JWT -Algorithm 'HS256' -type 'JWT' -Issuer 123 -SecretKey 456 -ValidforSeconds 30)
        $parsedToken = (Parse-JWTtoken -Token $token)
        $parsedToken.'alg' | Should -Be 'HS256'
        $parsedToken.'typ' | Should -Be 'JWT'
        $parsedToken.'iss' | Should -Be '123'
        $parsedToken.'exp' | Should -Not -BeNullOrEmpty
    }

    It 'Should create the correct headers' {
        $headers = New-ZoomHeaders -ApiKey 123 -ApiSecret 456
        $headers.'content-type' | Should -Be 'application/json'
        $headers.'authorization'  | Should -BeLike '*bearer*'
    }
}

Describe "PSZoom Meeting Tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version 'latest'

        It 'Should load' {
            $MeetingCommands = @(
                'Add-ZoomMeetingRegistrant',
                'Get-ZoomEndedMeetingInstances',
                'Get-ZoomMeeting',
                'Get-ZoomMeetingInvitation',
                'Get-ZoomMeetingPoll',
                'Get-ZoomMeetingRegistrants',
                'Get-ZoomMeetingsFromUser',
                'Get-ZoomPastMeetingDetails',
                'Get-ZoomPastMeetingParticipants',
                'Get-ZoomRegistrationQuestions',
                'Get-ZoomTelephoneReports',
                'New-ZoomMeetingPoll',
                'Remove-ZoomMeeting',
                'Remove-ZoomMeetingPoll',
                'Update-MeetingStatus',
                'Update-ZoomMeeting',
                'Update-ZoomMeetingLiveStream',
                'Update-ZoomMeetingPoll',
                'Update-ZoomMeetingRegistrantStatus'
            )
            
            $MeetingCommands | ForEach-Object {
                $MeetingCommands -contains $_ | Should Be $true
            }
        }
    }
}

Describe "PSZoom User Tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version 'latest'

        It 'Should load' {
            $UserCommands = @(
                'Get-ZoomRegistrationQuestions',
                'Get-ZoomSpecificUser',
                'Get-ZoomTelephoneReports',
                'Get-ZoomUserAssistants',
                'Get-ZoomUserEmailStatus',
                'Get-ZoomUserPermissions',
                'Get-ZoomUsers',
                'Get-ZoomUserSchedulers',
                'Get-ZoomUserSettings',
                'Get-ZoomUserToken',
                'New-ZoomUser',
                'Remove-ZoomSpecificUserAssistant',
                'Remove-ZoomSpecificUserScheduler',
                'Remove-ZoomUser',
                'Remove-ZoomUserAssistants',
                'Remove-ZoomUserSchedulers',
                'Revoke-ZoomUserSsoToken',
                'Update-ZoomProfilePicture',
                'Update-ZoomUser',
                'Update-ZoomUserEmail',
                'Update-ZoomUserpassword',
                'Update-ZoomUserSettings',
                'Update-ZoomUserStatus'
            )
            
            $UserCommands | ForEach-Object {
                $UserCommands -contains $_ | Should Be $true
            }
        }
    }
}

Describe "PSZoom Group Tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version 'latest'
        $GroupCommands = @(
                'Add-ZoomGroupMember',
                'Get-ZoomGroupLockSettings',
                'Get-ZoomGroups',
                'Get-ZoomGroupSettings',
                'Get-ZoomSpecificGroup',
                'New-ZoomGroup',
                'Remove-ZoomGroup',
                'Remove-ZoomGroupMembers',
                'Update-ZoomGroup',
                'Update-ZoomGroupLockSettings',
                'Update-ZoomGroupSettings'
        )

        It 'Should load' {
            $GroupCommands | ForEach-Object {
                $GroupCommands -contains $_ | Should Be $True
            }
        }
    }
    
    Context "Add-ZoomGroupMember" {
        $schema = '{
            "type": "object",
            "properties": {
              "members": {
                "type": "array",
                "description": "List of Group members",
                "maximum": 30,
                "items": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "string",
                      "description": "User ID."
                    },
                    "email": {
                      "type": "string",
                      "description": "User email. If the user ID is given then the user email should be ignored."
                    }
                  }
                }
              }
            }
          }'
        
        $request = Add-ZoomGroupMember -GroupId $GroupId -MemberEmail $UserEmail -ApiKey 123 -ApiSecret 456
        
        It "Uses the correct method" {
            $request.Method | Should Be 'POST'
        }
        
        It "Uses the correct uri" {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups/$GroupId/members"
        }
        
        It "Validates against the JSON schema" {
            Test-Json -Json $request.Body -Schema $schema | Should Be $True
        }
    }

    Context "Get-ZoomGroup" {
        $request = Get-ZoomGroup -GroupId $GroupId -ApiKey 123 -ApiSecret 456

        It "Uses the correct method" {
            $request.Method | Should Be 'GET'
        }
    
        It "Uses the correct uri" {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups/$GroupId"
        }
    }

    Context "Get-ZoomGroupLockSettings" {
        $request = Get-ZoomGroupLockSettings -GroupId $GroupId -ApiKey 123 -ApiSecret 456

        It "Uses the correct method" {
            $request.Method | Should Be 'GET'
        }
    
        It "Uses the correct uri" {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups/$GroupId/lock_settings"
        }
    }

    Context "Get-ZoomGroups" {
        $request = Get-ZoomGroups -FullApiResponse -ApiKey 123 -ApiSecret 456 

        It "Uses the correct method" {
            $request.Method | Should Be 'GET'
        }
    
        It "Uses the correct uri" {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups"
        }
    }

    Context "Get-ZoomGroupSettings" {
        $request = Get-ZoomGroupSettings -GroupId $GroupId -ApiKey 123 -ApiSecret 456

        It "Uses the correct method" {
            $request.Method | Should Be 'GET'
        }
    
        It "Uses the correct uri" {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups/$GroupId/settings"
        }
    }

    Context "New-ZoomGroup" {
        $schema = '{
            "type": "object",
            "properties": {
                "name": {
                "type": "string",
                "description": "Group name."
                }
            }
        }'
        
        $request = New-ZoomGroup -Name 'TestGroupName' -ApiKey 123 -ApiSecret 456
    
        It "Uses the correct method" {
            $request.Method | Should Be 'POST'
        }
    
        It "Uses the correct uri" {
            $request.Uri | Should Be 'https://api.zoom.us/v2/groups'
        }
    
        It "Validates against the JSON schema" {
            Test-Json -Json $request.Body -Schema $schema | Should Be $True
        }
    }

    Context 'Remove-ZoomGroup' {
        $request = Remove-ZoomGroup -GroupId $GroupId -ApiKey 123 -ApiSecret 456
    
        It "Uses the correct method" {
            $request.Method | Should Be 'DELETE'
        }
    
        It "Uses the correct uri" {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups/$GroupId"
        }
    }

    Context 'Update-ZoomGroup' {
        $schema = '{
            "type": "object",
            "properties": {
              "name": {
                "type": "string",
                "description": "Group name. It must be unique to one account and less than 128 characters."
              }
            }
          }'
        
        $request = Update-ZoomGroup -GroupId $GroupId -Name 'NewName' -ApiKey 123 -ApiSecret 456
    
        It 'Uses the correct method' {
            $request.Method | Should Be 'PATCH'
        }
    
        It 'Uses the correct uri' {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups/$GroupId"
        }
    
        It 'Validates against the JSON schema' {
            Test-Json -Json $request.Body -Schema $schema | Should Be $True
        }
    }

    $updateGroupParams = @{
        AccountUserAccessRecording      = $true
        AlertGuestJoin                  = $true
        AllowShowZoomWindows            = $true
        AlternativeHostReminder         = $true
        Annotation                      = $true
        AttendeeOnHold                  = $true
        AttentionTracking               = $true
        AudioConferenceInfo             = 'testaudioconferenceinfo'
        AudioType                       = $true
        AutoAnswer                      = $true
        AutoRecording                   = $true
        AutoSavingChat                  = $true
        BreakoutRoom                    = $true
        CancelMeetingReminder           = $true
        Chat                            = $true
        ClosedCaption                   = $true
        CloudRecording                  = $true
        CloudRecordingAvailableReminder = $true
        CloudRecordingDownload          = $true
        CloudRecordingDownloadHost      = $true
        CoHost                          = $true
        E2eEncryption                   = $true
        EntryExitChime                  = 'testchime'
        FarEndCameraControl             = $true
        Feedback                        = $true
        FileTransfer                    = $true
        ForcePmiJbhPassword             = $true
        GroupHd                         = $true
        HostDeleteCloudRecording        = $true
        HostVideo                       = $true
        JbhReminder                     = $true
        JoinBeforeHost                  = $true
        LocalRecording                  = $true
        MuteUponEntry                   = $true
        NonVerbalFeedback               = $true
        OnlyHostViewDeviceList          = $true
        OriginalAudio                   = $true
        ParticipantVideo                = $true
        Polling                         = $true
        PostMeetingFeedback             = $true
        PrivateChat                     = $true
        PstnPasswordProtected           = $true
        RecordAudioFile                 = $true
        RecordGalleryView               = $true
        RecordingAudioTranscript        = $true
        RecordPlayOwnVoice              = $true
        RecordSpeakerView               = $true
        RemoteControl                   = $true
        RemoteSupport                   = $true
        RequirePasswordForAllMeetings   = $true
        SaveChatText                    = $true
        ScheduleForHostReminder         = $true
        ScreenSharing                   = $true
        SendingDefaultEmailInvites      = $true
        ShowBrowserJoinLink             = $true
        ShowDeviceList                  = $true
        ShowMeetingControlToolbar       = $true
        ShowTimestamp                   = $true
        StereoAudio                     = $true
        ThirdPartyAudio                 = $true
        UpcomingMeetingReminder         = $true
        UseHtmlFormatEmail              = $true
        VirtualBackground               = $true
        WaitingRoom                     = $true
        Whiteboard                      = $true
    }
    Context 'Update-ZoomGroupLockSettings' -Verbose {
        $schema = '{
            "type": "object",
            "properties": {
              "schedule_meeting": {
                "type": "object",
                "properties": {
                  "host_video": {
                    "type": "boolean",
                    "description": "Start meetings with host video on."
                  },
                  "participant_video": {
                    "type": "boolean",
                    "description": "Start meetings with participant video on."
                  },
                  "audio_type": {
                    "type": "boolean",
                    "description": "Determine how participants can join the audio portion of the meeting."
                  },
                  "join_before_host": {
                    "type": "boolean",
                    "description": "Allow participants to join the meeting before the host arrives"
                  },
                  "force_pmi_jbh_password": {
                    "type": "boolean",
                    "description": "If join before host option is enabled for a personal meeting, then enforce password requirement."
                  },
                  "pstn_password_protected": {
                    "type": "boolean",
                    "description": "Generate and send new passwords for newly scheduled or edited meetings."
                  },
                  "mute_upon_entry": {
                    "type": "boolean",
                    "description": "Automatically mute all participants when they join the meeting."
                  },
                  "upcoming_meeting_reminder": {
                    "type": "boolean",
                    "description": "Receive desktop notification for upcoming meetings."
                  }
                }
              },
              "in_meeting": {
                "type": "object",
                "properties": {
                  "e2e_encryption": {
                    "type": "boolean",
                    "description": "Require that all meetings are encrypted using AES."
                  },
                  "chat": {
                    "type": "boolean",
                    "description": "Allow meeting participants to send chat message visible to all participants."
                  },
                  "private_chat": {
                    "type": "boolean",
                    "description": "Allow meeting participants to send a private 1:1 message to another participant."
                  },
                  "auto_saving_chat": {
                    "type": "boolean",
                    "description": "Automatically save all in-meeting chats."
                  },
                  "entry_exit_chime": {
                    "type": "string",
                    "description": "Play sound when participants join or leave."
                  },
                  "file_transfer": {
                    "type": "boolean",
                    "description": "Allow hosts and participants to send files through the in-meeting chat."
                  },
                  "feedback": {
                    "type": "boolean",
                    "description": "Enable users to provide feedback to Zoom at the end of the meeting."
                  },
                  "post_meeting_feedback": {
                    "type": "boolean",
                    "description": "Display end-of-meeting experience feedback survey."
                  },
                  "co_host": {
                    "type": "boolean",
                    "description": "Allow the host to add co-hosts. Co-hosts have the same in-meeting controls as the host."
                  },
                  "polling": {
                    "type": "boolean",
                    "description": "Add Polls to the meeting controls. This allows the host to survey the attendees."
                  },
                  "attendee_on_hold": {
                    "type": "boolean",
                    "description": "Allow hosts to temporarily remove an attendee from the meeting."
                  },
                  "show_meeting_control_toolbar": {
                    "type": "boolean",
                    "description": "Always show meeting controls during a meeting."
                  },
                  "allow_show_zoom_windows": {
                    "type": "boolean",
                    "description": "Show Zoom windows during screen share."
                  },
                  "annotation": {
                    "type": "boolean",
                    "description": "Allow participants to use annotation tools to add information to shared screens."
                  },
                  "whiteboard": {
                    "type": "boolean",
                    "description": "Allow participants to share a whiteboard that includes annotation tools."
                  },
                  "remote_control": {
                    "type": "boolean",
                    "description": "During screen sharing, allow the person who is sharing to let others control the shared content."
                  },
                  "non_verbal_feedback": {
                    "type": "boolean",
                    "description": "Allow participants in a meeting can provide nonverbal feedback and express opinions by clicking on icons in the Participants panel."
                  },
                  "breakout_room": {
                    "type": "boolean",
                    "description": "Allow host to split meeting participants into separate, smaller rooms."
                  },
                  "remote_support": {
                    "type": "boolean",
                    "description": "Allow meeting host to provide 1:1 remote support to another participant."
                  },
                  "closed_caption": {
                    "type": "boolean",
                    "description": "Allow host to type closed captions or assign a participant/third party device to add closed captions."
                  },
                  "far_end_camera_control": {
                    "type": "boolean",
                    "description": "Allow another user to take control of the camera during a meeting."
                  },
                  "group_hd": {
                    "type": "boolean",
                    "description": "Enable higher quality video for host and participants. This will require more bandwidth."
                  },
                  "virtual_background": {
                    "type": "boolean",
                    "description": "Enable virtual background."
                  },
                  "alert_guest_join": {
                    "type": "boolean",
                    "description": "Allow participants who belong to your account to see that a guest (someone who does not belong to your account) is participating in the meeting/webinar."
                  },
                  "auto_answer": {
                    "type": "boolean",
                    "description": "Enable users to see and add contacts to auto-answer group in the contact list on chat. Any call from members of this group will be automatically answered."
                  },
                  "sending_default_email_invites": {
                    "type": "boolean",
                    "description": "Allow users to invite participants by email only by default."
                  },
                  "use_html_format_email": {
                    "type": "boolean",
                    "description": "Allow  HTML formatting instead of plain text for meeting invitations scheduled with the Outlook plugin."
                  },
                  "stereo_audio": {
                    "type": "boolean",
                    "description": "Allow users to select stereo audio during a meeting."
                  },
                  "original_audio": {
                    "type": "boolean",
                    "description": "Allow users to select original sound during a meeting."
                  },
                  "screen_sharing": {
                    "type": "boolean",
                    "description": "Allow host and participants to share their screen or content during meetings."
                  },
                  "attention_tracking": {
                    "type": "boolean",
                    "description": "Allow the host to see an indicator in the participant panel if a meeting/webinar attendee does not have Zoom in focus during screen sharing."
                  },
                  "waiting_room": {
                    "type": "boolean",
                    "description": "Attendees cannot join a meeting until a host admits them individually from the waiting room."
                  },
                  "show_browser_join_link": {
                    "type": "boolean",
                    "description": "Allow participants to join a meeting directly from their browser."
                  }
                }
              },
              "email_notification": {
                "type": "object",
                "properties": {
                  "cloud_recording_available_reminder": {
                    "type": "boolean",
                    "description": "Notify host when cloud recording is available."
                  },
                  "jbh_reminder": {
                    "type": "boolean",
                    "description": "Notify host when participants join the meeting before them."
                  },
                  "cancel_meeting_reminder": {
                    "type": "boolean",
                    "description": "Notify host and participants when the meeting is cancelled."
                  },
                  "alternative_host_reminder": {
                    "type": "boolean",
                    "description": "Notify the alternative host who is set or removed."
                  },
                  "schedule_for_host_reminder": {
                    "type": "boolean",
                    "description": "Notify the host there is a meeting is scheduled, rescheduled, or cancelled."
                  }
                }
              },
              "recording": {
                "type": "object",
                "properties": {
                  "local_recording": {
                    "type": "boolean",
                    "description": "Allow hosts and participants to record the meeting to a local file."
                  },
                  "cloud_recording": {
                    "type": "boolean",
                    "description": "Allow hosts to record and save the meeting / webinar in the cloud."
                  },
                  "auto_recording": {
                    "type": "string",
                    "description": "Record meetings automatically as they start."
                  },
                  "cloud_recording_download": {
                    "type": "boolean",
                    "description": "Allow anyone with a link to the cloud recording to download."
                  },
                  "account_user_access_recording": {
                    "type": "boolean",
                    "description": "Make cloud recordings accessible to account members only."
                  },
                  "host_delete_cloud_recording": {
                    "type": "boolean",
                    "description": "Allow the host to delete the recordings. If this option is disabled, the recordings cannot be deleted by the host and only admin can delete them."
                  },
                  "auto_delete_cmr": {
                    "type": "boolean",
                    "description": "Allow Zoom to automatically delete recordings permanently after a specified number of days."
                  }
                }
              },
              "telephony": {
                "type": "object",
                "properties": {
                  "third_party_audio": {
                    "type": "boolean",
                    "description": "Allow users to join the meeting using the existing 3rd party audio configuration."
                  }
                }
              }
            }
          }'
        
        $request = Update-ZoomGroupLockSettings -GroupId $GroupId @updateGroupParams -ApiKey 123 -ApiSecret 456
        write-verbose $request.body
        It 'Uses the correct method' {
            $request.Method | Should Be 'PATCH'
        }
    
        It 'Uses the correct uri' {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups/$GroupId/lock_settings"
        }
    
        It 'Validates against the JSON schema' {
            Test-Json -Json $request.Body -Schema $schema | Should Be $True
        }
    }

    Context 'Update-ZoomGroupSettings' {
        $schema = '{
            "type": "object",
            "properties": {
              "name": {
                "type": "string",
                "description": "Group name. It must be unique to one account and less than 128 characters."
              }
            }
          }'
        
        $request = Update-ZoomGroupSettings -GroupId $GroupId @updateGroupParams -ApiKey 123 -ApiSecret 456
    
        It 'Uses the correct method' {
            $request.Method | Should Be 'PATCH'
        }
    
        It 'Uses the correct uri' {
            $request.Uri | Should Be "https://api.zoom.us/v2/groups/$GroupId/settings"
        }
    
        It 'Validates against the JSON schema' {
            Test-Json -Json $request.Body -Schema $schema | Should Be $True
        }
    }
}

Describe "PSZoom Report Tests" {
    Context 'Strict mode' {
        Set-StrictMode -Version 'latest'

        Mock Invoke-RestMethod {
            Write-Output $Body,$Uri,$Method
        }

        $ReportCommands = @(
                'Get-ZoomActiveInactiveHostReports',
                'Get-ZoomTelephoneReports'
        )

        It 'Should load' {
            $ReportCommands | ForEach-Object {
                $ReportCommands -contains $_ | Should Be $True
            }
        }
    }
}