BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomMeetingRecordingsSettings' {
    Context 'When updating recording settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Update-ZoomMeetingRecordingsSettings -MeetingId '1234567890' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct settings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/recordings/settings'
                return @{}
            }

            Update-ZoomMeetingRecordingsSettings -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomMeetingRecordingsSettings -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Share settings parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept ShareRecording parameter' {
            { Update-ZoomMeetingRecordingsSettings -MeetingId '1234567890' -ShareRecording 'publicly' } | Should -Not -Throw
        }

        It 'Should accept ViewerDownload parameter' {
            { Update-ZoomMeetingRecordingsSettings -MeetingId '1234567890' -ViewerDownload $true } | Should -Not -Throw
        }

        It 'Should accept Password parameter' {
            { Update-ZoomMeetingRecordingsSettings -MeetingId '1234567890' -Password 'secret123' } | Should -Not -Throw
        }

        It 'Should accept OnDemand parameter' {
            { Update-ZoomMeetingRecordingsSettings -MeetingId '1234567890' -OnDemand $true } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept MeetingId from pipeline' {
            { '1234567890' | Update-ZoomMeetingRecordingsSettings } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Update-ZoomMeetingRecordingsSettings } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found')
            }

            { Update-ZoomMeetingRecordingsSettings -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
