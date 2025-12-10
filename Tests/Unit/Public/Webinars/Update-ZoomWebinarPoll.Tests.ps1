BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomWebinarPoll' {
    Context 'When updating a poll' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123' -Title 'Updated Poll'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/polls/poll123*'
            }
        }

        It 'Should use PUT method' {
            Update-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123' -Title 'Updated Poll'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Put'
            }
        }

        It 'Should require WebinarId parameter' {
            { Update-ZoomWebinarPoll -PollId 'poll123' -Title 'Test' } | Should -Throw
        }

        It 'Should require PollId parameter' {
            { Update-ZoomWebinarPoll -WebinarId 1234567890 -Title 'Test' } | Should -Throw
        }

        It 'Should accept optional Title parameter' {
            { Update-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123' -Title 'Updated' } | Should -Not -Throw
        }

        It 'Should accept optional Questions parameter' {
            $questions = @(@{ name = 'Q1'; type = 'single'; answers = @('A', 'B') })
            { Update-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123' -Questions $questions } | Should -Not -Throw
        }
    }
}
