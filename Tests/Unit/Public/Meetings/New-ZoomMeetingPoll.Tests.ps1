BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomMeetingPoll' {
    Context 'When creating a meeting poll' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'poll123'
                    title = 'Test Poll'
                    status = 'notstart'
                }
            }
        }

        It 'Should create poll with MeetingId only' {
            $result = New-ZoomMeetingPoll -MeetingId '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should create poll with Title' {
            $result = New-ZoomMeetingPoll -MeetingId '1234567890' -Title 'Test Poll'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should create poll with Questions' {
            $questions = @(
                @{name = 'Question 1?'; type = 'single'; answers = @('Yes', 'No')}
            )
            $result = New-ZoomMeetingPoll -MeetingId '1234567890' -Title 'Test' -Questions $questions
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct polls endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/polls'
                return @{ id = 'poll123' }
            }

            New-ZoomMeetingPoll -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{ id = 'poll123' }
            }

            New-ZoomMeetingPoll -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { New-ZoomMeetingPoll } | Should -Throw
        }

        It 'Should accept optional Title parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
            { New-ZoomMeetingPoll -MeetingId '1234567890' -Title 'Test' } | Should -Not -Throw
        }

        It 'Should accept optional Questions parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
            $questions = @(@{name = 'Q?'; type = 'single'; answers = @('A', 'B')})
            { New-ZoomMeetingPoll -MeetingId '1234567890' -Questions $questions } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { New-ZoomMeetingPoll -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
