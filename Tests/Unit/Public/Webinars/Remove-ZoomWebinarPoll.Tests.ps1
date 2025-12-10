BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomWebinarPoll' {
    Context 'When deleting a poll' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/polls/poll123*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomWebinarPoll -WebinarId 1234567890 -PollId 'poll123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should require WebinarId parameter' {
            { Remove-ZoomWebinarPoll -PollId 'poll123' -Confirm:$false } | Should -Throw
        }

        It 'Should require PollId parameter' {
            { Remove-ZoomWebinarPoll -WebinarId 1234567890 -Confirm:$false } | Should -Throw
        }

        It 'Should accept pipeline input for PollId' {
            'poll123' | Remove-ZoomWebinarPoll -WebinarId 1234567890 -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
