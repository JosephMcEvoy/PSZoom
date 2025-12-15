BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPastMeetingParticipants' {
    Context 'When retrieving past meeting participants' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ participants = @(@{ id = 'user123'; name = 'John Doe' }) }
            }
        }

        It 'Should return participants' {
            $result = Get-ZoomPastMeetingParticipants -MeetingUuid 'abc123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return participants array' {
            $result = Get-ZoomPastMeetingParticipants -MeetingUuid 'abc123'
            $result.participants | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct participants endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/past_meetings/.*/participants'
                return @{ participants = @() }
            }

            Get-ZoomPastMeetingParticipants -MeetingUuid 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ participants = @() }
            }
        }

        It 'Should accept MeetingUuid from pipeline' {
            $result = 'abc123' | Get-ZoomPastMeetingParticipants
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingUuid parameter' {
            { Get-ZoomPastMeetingParticipants } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Get-ZoomPastMeetingParticipants -MeetingUuid 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
