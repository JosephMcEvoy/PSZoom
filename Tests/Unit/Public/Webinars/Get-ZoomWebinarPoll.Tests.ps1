BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinarPoll' {
    Context 'When retrieving a poll' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'poll123'
                    title = 'Test Poll'
                    status = 'notstart'
                    questions = @(@{ name = 'Q1'; type = 'single'; answers = @('A', 'B') })
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/polls/poll123*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomWebinarPoll -PollId 'poll123' } | Should -Throw
        }

        It 'Should require PollId parameter' {
            { Get-ZoomWebinarPoll -WebinarId 1234567890 } | Should -Throw
        }

        It 'Should accept pipeline input for PollId' {
            'poll123' | Get-ZoomWebinarPoll -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return poll details' {
            $result = Get-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123'

            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'poll123'
            $result.title | Should -Be 'Test Poll'
        }
    }
}
