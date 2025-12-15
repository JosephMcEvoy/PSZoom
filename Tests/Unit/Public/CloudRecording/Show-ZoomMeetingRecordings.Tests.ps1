BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Show-ZoomMeetingRecordings' {
    Context 'When recovering meeting recordings from trash' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Show-ZoomMeetingRecordings -MeetingId '1234567890' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct recordings status endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/recordings/status'
                return @{}
            }

            Show-ZoomMeetingRecordings -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PUT method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PUT'
                return @{}
            }

            Show-ZoomMeetingRecordings -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept MeetingId from pipeline' {
            { '1234567890' | Show-ZoomMeetingRecordings } | Should -Not -Throw
        }

        It 'Should process multiple MeetingIds' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }

            @('meeting1', 'meeting2') | Show-ZoomMeetingRecordings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Show-ZoomMeetingRecordings } | Should -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept MeetingId as first positional parameter' {
            { Show-ZoomMeetingRecordings '1234567890' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found in trash')
            }

            { Show-ZoomMeetingRecordings -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
