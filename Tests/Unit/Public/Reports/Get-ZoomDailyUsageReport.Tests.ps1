BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomDailyUsageReport' {
    Context 'When retrieving daily usage report' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    year = 2025
                    month = 1
                    dates = @(
                        @{
                            date = '2025-01-01'
                            meetings = 10
                            participants = 50
                            meeting_minutes = 300
                        }
                        @{
                            date = '2025-01-02'
                            meetings = 15
                            participants = 75
                            meeting_minutes = 450
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomDailyUsageReport -Year 2025 -Month 1

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/report/daily*'
            }
        }

        It 'Should require Year parameter' {
            { Get-ZoomDailyUsageReport -Month 1 } | Should -Throw
        }

        It 'Should require Month parameter' {
            { Get-ZoomDailyUsageReport -Year 2025 } | Should -Throw
        }

        It 'Should include year in query string' {
            Get-ZoomDailyUsageReport -Year 2025 -Month 1

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'year=2025'
            }
        }

        It 'Should include month in query string' {
            Get-ZoomDailyUsageReport -Year 2025 -Month 1

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'month=1'
            }
        }

        It 'Should accept pipeline input for Year and Month by property name' {
            $params = [PSCustomObject]@{ Year = 2025; Month = 1 }
            $params | Get-ZoomDailyUsageReport

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return the response object' {
            $result = Get-ZoomDailyUsageReport -Year 2025 -Month 1

            $result | Should -Not -BeNullOrEmpty
            $result.year | Should -Be 2025
            $result.month | Should -Be 1
            $result.dates | Should -HaveCount 2
        }

        It 'Should use GET method' {
            Get-ZoomDailyUsageReport -Year 2025 -Month 1

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ year = 2025; month = 1; dates = @() }
            }
        }

        It 'Should accept valid year value' {
            { Get-ZoomDailyUsageReport -Year 2025 -Month 1 } | Should -Not -Throw
        }

        It 'Should accept valid month values (1-12)' {
            { Get-ZoomDailyUsageReport -Year 2025 -Month 1 } | Should -Not -Throw
            { Get-ZoomDailyUsageReport -Year 2025 -Month 12 } | Should -Not -Throw
        }

        It 'Should accept month as integer parameter' {
            Get-ZoomDailyUsageReport -Year 2025 -Month 6

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'month=6'
            }
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Invalid month/year'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomDailyUsageReport -Year 2025 -Month 1 } | Should -Throw
        }
    }
}
