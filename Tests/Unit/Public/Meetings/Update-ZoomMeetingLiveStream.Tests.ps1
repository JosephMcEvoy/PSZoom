BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomMeetingLiveStream' {
    Context 'When updating live stream settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Update-ZoomMeetingLiveStream -MeetingId '1234567890' -StreamUrl 'rtmp://example.com/live' -StreamKey 'key123' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct livestream endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/livestream'
                return @{}
            }

            Update-ZoomMeetingLiveStream -MeetingId '1234567890' -StreamUrl 'rtmp://example.com/live' -StreamKey 'key123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomMeetingLiveStream -MeetingId '1234567890' -StreamUrl 'rtmp://example.com/live' -StreamKey 'key123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Update-ZoomMeetingLiveStream -StreamUrl 'rtmp://example.com/live' -StreamKey 'key123' } | Should -Throw
        }

        It 'Should require StreamUrl parameter' {
            { Update-ZoomMeetingLiveStream -MeetingId '1234567890' -StreamKey 'key123' } | Should -Throw
        }

        It 'Should require StreamKey parameter' {
            { Update-ZoomMeetingLiveStream -MeetingId '1234567890' -StreamUrl 'rtmp://example.com/live' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Update-ZoomMeetingLiveStream -MeetingId 'nonexistent' -StreamUrl 'rtmp://test' -StreamKey 'key' -ErrorAction Stop } | Should -Throw
        }
    }
}
