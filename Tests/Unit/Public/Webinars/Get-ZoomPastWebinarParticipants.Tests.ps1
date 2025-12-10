BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPastWebinarParticipants' {
    Context 'When retrieving past webinar participants' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 1
                    page_size = 30
                    total_records = 2
                    participants = @(
                        @{ id = 'part1'; name = 'John Doe'; email = 'john@company.com' }
                        @{ id = 'part2'; name = 'Jane Smith'; email = 'jane@company.com' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomPastWebinarParticipants -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/past_webinars/1234567890/participants*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomPastWebinarParticipants -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomPastWebinarParticipants } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Get-ZoomPastWebinarParticipants

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return participants' {
            $result = Get-ZoomPastWebinarParticipants -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
            $result.total_records | Should -Be 2
        }
    }
}
