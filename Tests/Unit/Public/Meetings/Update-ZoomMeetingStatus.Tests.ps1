BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomMeetingStatus' {
    Context 'When updating meeting status' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error with MeetingId only' {
            { Update-ZoomMeetingStatus -MeetingId '1234567890' } | Should -Not -Throw
        }

        It 'Should complete without error with Action parameter' {
            { Update-ZoomMeetingStatus -MeetingId '1234567890' -Action 'end' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct status endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/status'
                return @{}
            }

            Update-ZoomMeetingStatus -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PUT method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PUT'
                return @{}
            }

            Update-ZoomMeetingStatus -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Action parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept end action' {
            { Update-ZoomMeetingStatus -MeetingId '1234567890' -Action 'end' } | Should -Not -Throw
        }

        It 'Should default to end action' {
            # Action defaults to 'end', so it should work without specifying Action
            { Update-ZoomMeetingStatus -MeetingId '1234567890' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Update-ZoomMeetingStatus -Action 'end' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Update-ZoomMeetingStatus -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
