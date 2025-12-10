BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPastWebinarPolls' {
    Context 'When retrieving past webinar poll results' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 1234567890
                    uuid = 'abc123'
                    questions = @(
                        @{ name = 'Q1'; email = 'john@company.com'; question_details = @(@{ question = 'What?'; answer = 'A' }) }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomPastWebinarPolls -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/past_webinars/1234567890/polls*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomPastWebinarPolls -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomPastWebinarPolls } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Get-ZoomPastWebinarPolls

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return poll results' {
            $result = Get-ZoomPastWebinarPolls -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
        }
    }
}
