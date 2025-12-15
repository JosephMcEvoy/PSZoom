BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomMeetingLiveStreamStatus' {
    Context 'When updating live stream status' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Update-ZoomMeetingLiveStreamStatus -MeetingId '1234567890' } | Should -Not -Throw
        }

        It 'Should accept StreamUrl parameter' {
            { Update-ZoomMeetingLiveStreamStatus -MeetingId '1234567890' -StreamUrl 'rtmp://example.com/live' } | Should -Not -Throw
        }

        It 'Should accept StreamKey parameter' {
            { Update-ZoomMeetingLiveStreamStatus -MeetingId '1234567890' -StreamKey 'abc123' } | Should -Not -Throw
        }

        It 'Should accept PageUrl parameter' {
            { Update-ZoomMeetingLiveStreamStatus -MeetingId '1234567890' -PageUrl 'https://example.com/page' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct livestream status endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/livestream/status'
                return @{}
            }

            Update-ZoomMeetingLiveStreamStatus -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomMeetingLiveStreamStatus -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Update-ZoomMeetingLiveStreamStatus } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Update-ZoomMeetingLiveStreamStatus -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
