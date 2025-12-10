BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomWebinarPoll' {
    Context 'When creating a poll' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'poll123'
                    title = 'Test Poll'
                    status = 'notstart'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            $questions = @(@{ name = 'Q1'; type = 'single'; answers = @('A', 'B') })
            New-ZoomWebinarPoll -WebinarId 1234567890 -Title 'Test Poll' -Questions $questions

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/polls*'
            }
        }

        It 'Should use POST method' {
            $questions = @(@{ name = 'Q1'; type = 'single'; answers = @('A', 'B') })
            New-ZoomWebinarPoll -WebinarId 1234567890 -Title 'Test Poll' -Questions $questions

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should require WebinarId parameter' {
            $questions = @(@{ name = 'Q1'; type = 'single'; answers = @('A', 'B') })
            { New-ZoomWebinarPoll -Title 'Test' -Questions $questions } | Should -Throw
        }

        It 'Should require Title parameter' {
            $questions = @(@{ name = 'Q1'; type = 'single'; answers = @('A', 'B') })
            { New-ZoomWebinarPoll -WebinarId 1234567890 -Questions $questions } | Should -Throw
        }

        It 'Should require Questions parameter' {
            { New-ZoomWebinarPoll -WebinarId 1234567890 -Title 'Test' } | Should -Throw
        }

        It 'Should return the response object' {
            $questions = @(@{ name = 'Q1'; type = 'single'; answers = @('A', 'B') })
            $result = New-ZoomWebinarPoll -WebinarId 1234567890 -Title 'Test Poll' -Questions $questions

            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'poll123'
        }
    }
}
