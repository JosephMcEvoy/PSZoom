BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomActiveInactiveHostReports' {
    Context 'When retrieving active/inactive host reports with default parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    from = '2025-01-01'
                    to = '2025-01-31'
                    page_count = 1
                    page_size = 30
                    total_records = 2
                    total_meetings = 5
                    total_participants = 10
                    total_meeting_minutes = 120
                    users = @(
                        @{ id = 'user1'; email = 'user1@test.com'; user_name = 'User One' }
                        @{ id = 'user2'; email = 'user2@test.com'; user_name = 'User Two' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/report/users*'
            }
        }

        It 'Should include from and to parameters in query string' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'from=2025-01-01' -and $Uri -match 'to=2025-01-31'
            }
        }

        It 'Should use default type "inactive" when not specified' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'type=inactive'
            }
        }

        It 'Should accept Type parameter for active reports' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -Type 'active'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'type=active'
            }
        }

        It 'Should use default page size of 30' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Should accept custom PageSize parameter' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should use default page number of 1' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_number=1'
            }
        }

        It 'Should accept custom PageNumber parameter' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -PageNumber 2

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_number=2'
            }
        }

        It 'Should include NextPageToken when provided' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -NextPageToken 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31'

            $result | Should -Not -BeNullOrEmpty
            $result.users | Should -HaveCount 2
        }

        It 'Should use GET method' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }
    }

    Context 'When using CombineAllPages parameter' {
        BeforeEach {
            Mock Get-ZoomActiveInactiveHostReports -ModuleName PSZoom {
                if ($PageNumber -eq 1) {
                    return @{
                        from = '2025-01-01'
                        to = '2025-01-31'
                        page_count = 2
                        total_records = 4
                        total_meetings = 10
                        total_participants = 20
                        total_meeting_minutes = 240
                        next_page_token = 'token123'
                        users = @(
                            @{ id = 'user1' }
                            @{ id = 'user2' }
                        )
                    }
                } else {
                    return @{
                        users = @(
                            @{ id = 'user3' }
                            @{ id = 'user4' }
                        )
                    }
                }
            }
        }

        It 'Should combine users from all pages' {
            $result = Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -CombineAllPages

            $result.Users | Should -HaveCount 4
        }

        It 'Should set PageSize to 300 automatically' {
            Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -CombineAllPages

            Should -Invoke Get-ZoomActiveInactiveHostReports -ModuleName PSZoom -ParameterFilter {
                $PageSize -eq 300
            }
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' } | Should -Throw
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    from = '2025-01-01'
                    to = '2025-01-31'
                    users = @()
                }
            }
        }

        It 'Should accept valid Type values' {
            { Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -Type 'active' } | Should -Not -Throw
            { Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -Type 'inactive' } | Should -Not -Throw
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -PageSize 0 } | Should -Throw
            { Get-ZoomActiveInactiveHostReports -From '2025-01-01' -To '2025-01-31' -PageSize 301 } | Should -Throw
        }
    }
}
