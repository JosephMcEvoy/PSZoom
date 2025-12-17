BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomSchedulerAnalytics' {
    Context 'When retrieving scheduler analytics' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    from = '2024-01-01T00:00:00Z'
                    to = '2024-01-31T23:59:59Z'
                    total_events = 100
                    total_bookings = 250
                }
            }
        }

        It 'Should return analytics data' {
            $result = Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return analytics with correct date range' {
            $result = Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z'
            $result.from | Should -Be '2024-01-01T00:00:00Z'
            $result.to | Should -Be '2024-01-31T23:59:59Z'
        }

        It 'Should return analytics with total events' {
            $result = Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z'
            $result.total_events | Should -Be 100
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct analytics endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/scheduler/analytics'
                return @{}
            }

            Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include from parameter in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'from=2024-01-01T00%3a00%3a00Z'
                return @{}
            }

            Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include to parameter in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'to=2024-01-31T23%3a59%3a59Z'
                return @{}
            }

            Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{}
            }

            Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    from = '2024-01-01T00:00:00Z'
                    to = '2024-01-31T23:59:59Z'
                }
            }
        }

        It 'Should accept object with from and to properties from pipeline' {
            $dateRange = [PSCustomObject]@{
                from = '2024-01-01T00:00:00Z'
                to = '2024-01-31T23:59:59Z'
            }
            $result = $dateRange | Get-ZoomSchedulerAnalytics
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept start_date alias for From' {
            { Get-ZoomSchedulerAnalytics -start_date '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z' } | Should -Not -Throw
        }

        It 'Should accept end_date alias for To' {
            { Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -end_date '2024-01-31T23:59:59Z' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Invalid date range')
            }

            { Get-ZoomSchedulerAnalytics -From '2024-01-01T00:00:00Z' -To '2024-01-31T23:59:59Z' -ErrorAction Stop } | Should -Throw
        }
    }
}
