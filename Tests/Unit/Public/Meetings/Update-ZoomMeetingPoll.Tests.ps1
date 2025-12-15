BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomMeetingPoll' {
    Context 'When updating a meeting poll' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Update-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123' -Title 'Updated Poll' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct poll endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/polls/'
                return @{}
            }

            Update-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123' -Title 'Updated'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PUT method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PUT'
                return @{}
            }

            Update-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123' -Title 'Updated'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Update-ZoomMeetingPoll -PollId 'poll123' -Title 'Test' } | Should -Throw
        }

        It 'Should require PollId parameter' {
            { Update-ZoomMeetingPoll -MeetingId '1234567890' -Title 'Test' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Poll not found')
            }

            { Update-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'nonexistent' -Title 'Test' -ErrorAction Stop } | Should -Throw
        }
    }
}
