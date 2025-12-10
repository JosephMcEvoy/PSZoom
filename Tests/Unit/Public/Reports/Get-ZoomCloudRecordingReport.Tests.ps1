BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomCloudRecordingReport' {
    Context 'When retrieving cloud recording reports' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    from = '2025-01-01'
                    to = '2025-01-31'
                    cloud_recording_storage = @(
                        @{
                            date = '2025-01-15'
                            usage = 1024000000
                            plan_usage = 5368709120
                            free_usage = 0
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomCloudRecordingReport -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/report/cloud_recording*'
            }
        }

        It 'Should require From parameter' {
            { Get-ZoomCloudRecordingReport -To '2025-01-31' } | Should -Throw
        }

        It 'Should include from parameter in query string when provided' {
            Get-ZoomCloudRecordingReport -From '2025-01-01'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'from=2025-01-01'
            }
        }

        It 'Should include to parameter in query string when provided' {
            Get-ZoomCloudRecordingReport -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'to=2025-01-31'
            }
        }

        It 'Should accept pipeline input' {
            '2025-01-01' | Get-ZoomCloudRecordingReport

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return the response object' {
            $result = Get-ZoomCloudRecordingReport -From '2025-01-01' -To '2025-01-31'

            $result | Should -Not -BeNullOrEmpty
            $result.cloud_recording_storage | Should -Not -BeNullOrEmpty
        }

        It 'Should use GET method' {
            Get-ZoomCloudRecordingReport -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }
    }

    Context 'When validating date parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ cloud_recording_storage = @() }
            }
        }

        It 'Should accept valid date format yyyy-MM-dd' {
            { Get-ZoomCloudRecordingReport -From '2025-01-01' -To '2025-01-31' } | Should -Not -Throw
        }

        It 'Should reject invalid date format' {
            { Get-ZoomCloudRecordingReport -From '01-01-2025' -To '01-31-2025' } | Should -Throw
        }

        It 'Should reject date without leading zeros' {
            { Get-ZoomCloudRecordingReport -From '2025-1-1' -To '2025-1-31' } | Should -Throw
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Invalid date range'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomCloudRecordingReport -From '2025-01-01' -To '2025-01-31' } | Should -Throw
        }
    }
}
