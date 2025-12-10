BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPastWebinarQA' {
    Context 'When retrieving past webinar Q&A' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 1234567890
                    uuid = 'abc123'
                    questions = @(
                        @{ name = 'John'; email = 'john@company.com'; question = 'What is this?' }
                        @{ name = 'Jane'; email = 'jane@company.com'; question = 'How does it work?' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomPastWebinarQA -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/past_webinars/1234567890/qa*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomPastWebinarQA -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomPastWebinarQA } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Get-ZoomPastWebinarQA

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return Q&A data' {
            $result = Get-ZoomPastWebinarQA -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
            $result.questions.Count | Should -Be 2
        }
    }
}
