BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomSchedulerSchedules' {
    Context 'When listing scheduler schedules' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    schedules = @(
                        @{ id = 'schedule1'; name = 'Schedule One' },
                        @{ id = 'schedule2'; name = 'Schedule Two' }
                    )
                    next_page_token = ''
                    page_count = 1
                    total_records = 2
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Get-ZoomSchedulerSchedules

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/scheduler/schedules'
            }
        }

        It 'Should use GET method' {
            Get-ZoomSchedulerSchedules

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomSchedulerSchedules

            $result.schedules.Count | Should -Be 2
        }
    }

    Context 'When using pagination parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ schedules = @() }
            }
        }

        It 'Should include page_size in query when provided' {
            Get-ZoomSchedulerSchedules -PageSize 50

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_size=50'
            }
        }

        It 'Should include next_page_token in query when provided' {
            Get-ZoomSchedulerSchedules -NextPageToken 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should include multiple query parameters' {
            Get-ZoomSchedulerSchedules -PageSize 25 -NextPageToken 'abc'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_size=25' -and $Uri -match 'next_page_token=abc'
            }
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ schedules = @() }
            }
        }

        It 'Should accept page_size from pipeline by property name' {
            [PSCustomObject]@{ page_size = 50 } | Get-ZoomSchedulerSchedules

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_size=50'
            }
        }
    }

    Context 'Parameter validation' {
        It 'Should enforce PageSize range (1-100)' {
            { Get-ZoomSchedulerSchedules -PageSize 0 } | Should -Throw
            { Get-ZoomSchedulerSchedules -PageSize 101 } | Should -Throw
        }
    }
}
