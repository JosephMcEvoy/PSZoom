BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomUserSettings' {
    Context 'When updating user settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com/settings'
                $Method | Should -Be 'PATCH'
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'testuser@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should send request body as JSON' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                { $Body | ConvertFrom-Json } | Should -Not -Throw
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'testuser@example.com' -HostVideo $true
        }
    }

    Context 'Schedule meeting settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should include HostVideo in schedule_meeting section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule_meeting.host_video | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -HostVideo $true
        }

        It 'Should include ParticipantsVideo in schedule_meeting section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule_meeting.participants_video | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -ParticipantsVideo $true
        }

        It 'Should include AudioType in schedule_meeting section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule_meeting.audio_type | Should -Be 'voip'
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -AudioType 'voip'
        }

        It 'Should include JoinBeforeHost in schedule_meeting section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule_meeting.join_before_host | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -JoinBeforeHost $true
        }
    }

    Context 'In-meeting settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should include E2eEncryption in in_meeting section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.in_meeting.e2e_encryption | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -E2eEncryption $true
        }

        It 'Should include Chat in in_meeting section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.in_meeting.chat | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -Chat $true
        }

        It 'Should include WaitingRoom in in_meeting section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.in_meeting.waiting_room | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -WaitingRoom $true
        }
    }

    Context 'Recording settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should include LocalRecording in recording section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.recording.local_recording | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -LocalRecording $true
        }

        It 'Should include CloudRecording in recording section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.recording.cloud_recording | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -CloudRecording $true
        }

        It 'Should include AutoRecording in recording section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.recording.auto_recording | Should -Be 'cloud'
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -AutoRecording 'cloud'
        }
    }

    Context 'Feature settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should include MeetingCapacity in feature section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.feature.meeting_capacity | Should -Be 100
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -MeetingCapacity 100
        }

        It 'Should include LargeMeeting in feature section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.feature.large_meeting | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -LargeMeeting $true
        }

        It 'Should include Webinar in feature section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.feature.webinar | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -Webinar $true
        }
    }

    Context 'Telephony settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should include ThirdPartyAudio in telephony section with trailing space in key' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.telephony.'third_party_audio ' | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -ThirdPartyAudio $true
        }

        It 'Should include ShowInternationalNumbersLink in telephony section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.telephony.show_international_numbers_link | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -ShowInternationalNumbersLink $true
        }
    }

    Context 'TSP settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should include CallOut in tsp section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.tsp.call_out | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -CallOut $true
        }

        It 'Should include CallOutCountries in tsp section' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.tsp.call_out_countries | Should -Not -BeNullOrEmpty
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -CallOutCountries @('US', 'CA')
        }
    }

    Context 'ValidateSet parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept valid AudioType values' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -AudioType 'both' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -AudioType 'telephony' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -AudioType 'voip' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -AudioType 'thirdparty' } | Should -Not -Throw
        }

        It 'Should reject invalid AudioType values' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -AudioType 'invalid' } | Should -Throw
        }

        It 'Should accept valid EntryExitChime values' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -EntryExitChime 'host' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -EntryExitChime 'all' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -EntryExitChime 'none' } | Should -Not -Throw
        }

        It 'Should accept valid AutoRecording values' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -AutoRecording 'local' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -AutoRecording 'cloud' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -AutoRecording 'none' } | Should -Not -Throw
        }

        It 'Should accept valid RequirePasswordForPMIMeetings values' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -RequirePasswordForPMIMeetings 'jbh_only' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -RequirePasswordForPMIMeetings 'all' } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -RequirePasswordForPMIMeetings 'none' } | Should -Not -Throw
        }
    }

    Context 'ValidateRange parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept valid AutoDeleteCmrDays range (0-60)' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -AutoDeleteCmrDays 0 } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -AutoDeleteCmrDays 30 } | Should -Not -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -AutoDeleteCmrDays 60 } | Should -Not -Throw
        }

        It 'Should reject AutoDeleteCmrDays outside range' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -AutoDeleteCmrDays -1 } | Should -Throw
            { Update-ZoomUserSettings -UserId 'user@example.com' -AutoDeleteCmrDays 61 } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Update-ZoomUserSettings -HostVideo $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            @('user1@example.com', 'user2@example.com') | Update-ZoomUserSettings -HostVideo $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should return UserId when Passthru is specified' {
            $result = Update-ZoomUserSettings -UserId 'user@example.com' -HostVideo $true -PassThru
            $result | Should -Be 'user@example.com'
        }

        It 'Should return API response when Passthru is not specified' {
            $result = Update-ZoomUserSettings -UserId 'user@example.com' -HostVideo $true
            $result.status | Should -Be 'success'
        }
    }

    Context 'Multiple settings in one call' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should include multiple settings across different sections' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule_meeting.host_video | Should -Be $true
                $bodyObj.in_meeting.waiting_room | Should -Be $true
                $bodyObj.recording.cloud_recording | Should -Be $true
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -HostVideo $true -WaitingRoom $true -CloudRecording $true
        }
    }

    Context 'Only include specified settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should only include sections with specified parameters' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.PSObject.Properties.Name | Should -Contain 'schedule_meeting'
                $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'recording'
                $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'feature'
                return @{ status = 'success' }
            }

            Update-ZoomUserSettings -UserId 'user@example.com' -HostVideo $true
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Update-ZoomUserSettings -Email 'user@example.com' -HostVideo $true } | Should -Not -Throw
        }

        It 'Should accept host_video alias' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -host_video $true } | Should -Not -Throw
        }

        It 'Should accept participants_video alias' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -participants_video $true } | Should -Not -Throw
        }

        It 'Should accept join_before_host alias' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -join_before_host $true } | Should -Not -Throw
        }

        It 'Should accept cloud_recording alias' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -cloud_recording $true } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Update-ZoomUserSettings -UserId 'nonexistent@example.com' -HostVideo $true -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle permission errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Insufficient privileges')
            }

            { Update-ZoomUserSettings -UserId 'user@example.com' -HostVideo $true -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'CmdletBinding attributes' {
        It 'Should not have SupportsShouldProcess' {
            $cmd = Get-Command Update-ZoomUserSettings
            $attributes = $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $attributes.SupportsShouldProcess | Should -Not -Be $true
        }
    }

    Context 'UserId length validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId within valid length' {
            { Update-ZoomUserSettings -UserId 'user@example.com' -HostVideo $true } | Should -Not -Throw
        }

        It 'Should reject UserId exceeding 128 characters' {
            $longUserId = 'a' * 129
            { Update-ZoomUserSettings -UserId $longUserId -HostVideo $true } | Should -Throw
        }
    }
}
