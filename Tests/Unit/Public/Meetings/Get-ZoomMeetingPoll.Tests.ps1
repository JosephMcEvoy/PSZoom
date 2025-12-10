BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomMeetingPoll' {
    Context 'When retrieving a specific poll' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'poll123'; title = 'Test Poll'; questions = @() }
            }
        }

        It 'Should return poll details' {
            $result = Get-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return poll with id' {
            $result = Get-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123'
            $result.id | Should -Be 'poll123'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct poll endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/polls/'
                return @{ id = 'poll123' }
            }

            Get-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'poll123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Get-ZoomMeetingPoll -PollId 'poll123' } | Should -Throw
        }

        It 'Should require PollId parameter' {
            { Get-ZoomMeetingPoll -MeetingId '1234567890' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Poll not found')
            }

            { Get-ZoomMeetingPoll -MeetingId '1234567890' -PollId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
