BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinarPolls' {
    Context 'When retrieving webinar polls' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    polls = @(
                        @{ id = 'poll1'; title = 'Poll 1' }
                        @{ id = 'poll2'; title = 'Poll 2' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinarPolls -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/polls*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomWebinarPolls -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomWebinarPolls } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Get-ZoomWebinarPolls

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return polls' {
            $result = Get-ZoomWebinarPolls -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
            $result.polls.Count | Should -Be 2
        }
    }
}
