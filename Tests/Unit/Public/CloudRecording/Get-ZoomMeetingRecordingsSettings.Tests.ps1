BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    $script:MockRecordingSettings = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/recording-settings.json" | ConvertFrom-Json
}

Describe 'Get-ZoomMeetingRecordingsSettings' {
    Context 'When retrieving recording settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingSettings
            }
        }

        It 'Should return recording settings' {
            $result = Get-ZoomMeetingRecordingsSettings -MeetingId '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return share_recording setting' {
            $result = Get-ZoomMeetingRecordingsSettings -MeetingId '1234567890'
            $result.share_recording | Should -Not -BeNullOrEmpty
        }

        It 'Should return viewer_download setting' {
            $result = Get-ZoomMeetingRecordingsSettings -MeetingId '1234567890'
            $result.viewer_download | Should -BeTrue
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct settings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/recordings/settings'
                return $script:MockRecordingSettings
            }

            Get-ZoomMeetingRecordingsSettings -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockRecordingSettings
            }

            Get-ZoomMeetingRecordingsSettings -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockRecordingSettings
            }
        }

        It 'Should accept MeetingId from pipeline' {
            $result = '1234567890' | Get-ZoomMeetingRecordingsSettings
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Get-ZoomMeetingRecordingsSettings } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found')
            }

            { Get-ZoomMeetingRecordingsSettings -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
