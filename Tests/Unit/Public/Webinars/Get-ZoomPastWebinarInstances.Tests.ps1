BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPastWebinarInstances' {
    Context 'When retrieving past webinar instances' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    webinars = @(
                        @{ uuid = 'uuid1'; start_time = '2025-01-01T10:00:00Z' }
                        @{ uuid = 'uuid2'; start_time = '2025-01-08T10:00:00Z' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomPastWebinarInstances -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/past_webinars/1234567890/instances*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomPastWebinarInstances -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomPastWebinarInstances } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Get-ZoomPastWebinarInstances

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return instances' {
            $result = Get-ZoomPastWebinarInstances -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
            $result.webinars.Count | Should -Be 2
        }
    }
}
