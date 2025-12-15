BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomMeetingPoll' {
    Context 'When removing a meeting poll' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Remove-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct poll endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/polls/'
                return @{}
            }

            Remove-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use DELETE method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'DELETE'
                return @{}
            }

            Remove-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Remove-ZoomMeetingPoll -PollId 'poll123' } | Should -Throw
        }

        It 'Should require PollId parameter' {
            { Remove-ZoomMeetingPoll -MeetingId '1234567890' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Poll not found')
            }

            { Remove-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
