BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomTelephoneReports' {
    Context 'When retrieving telephone reports with default parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    from = '2025-01-01'
                    to = '2025-01-31'
                    page_count = 1
                    page_number = 1
                    page_size = 30
                    total_records = 2
                    telephony_usage = @(
                        @{
                            meeting_id = 'meet1'
                            phone_number = '+1234567890'
                            type = 'toll_free'
                            duration = 60
                            total = 1.50
                        }
                        @{
                            meeting_id = 'meet2'
                            phone_number = '+0987654321'
                            type = 'toll_free'
                            duration = 120
                            total = 3.00
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/report/telephone*'
            }
        }

        It 'Should require From parameter' {
            { Get-ZoomTelephoneReports -To '2025-01-31' } | Should -Throw
        }

        It 'Should require To parameter' {
            { Get-ZoomTelephoneReports -From '2025-01-01' } | Should -Throw
        }

        It 'Should include from parameter in query string' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'from=2025-01-01'
            }
        }

        It 'Should include to parameter in query string' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'to=2025-01-31'
            }
        }

        It 'Should use default type of 1' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'type=1'
            }
        }

        It 'Should use default page size of 30' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Should accept custom PageSize parameter' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should use default page number of 1' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_number=1'
            }
        }

        It 'Should accept custom PageNumber parameter' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -PageNumber 2

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_number=2'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31'

            $result | Should -Not -BeNullOrEmpty
            $result.telephony_usage | Should -HaveCount 2
        }

        It 'Should use GET method' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should accept pipeline input for From and To by property name' {
            $params = [PSCustomObject]@{ From = '2025-01-01'; To = '2025-01-31' }
            $params | Get-ZoomTelephoneReports

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'When using CombineAllPages parameter' {
        BeforeEach {
            Mock Get-ZoomTelephoneReports -ModuleName PSZoom {
                if ($PageNumber -eq 1) {
                    return @{
                        from = '2025-01-01'
                        to = '2025-01-31'
                        page_count = 2
                        total_records = 4
                        telephony_usage = @(
                            @{ meeting_id = 'meet1' }
                            @{ meeting_id = 'meet2' }
                        )
                    }
                } else {
                    return @{
                        telephony_usage = @(
                            @{ meeting_id = 'meet3' }
                            @{ meeting_id = 'meet4' }
                        )
                    }
                }
            }
        }

        It 'Should combine telephony usage from all pages' {
            $result = Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -CombineAllPages

            $result.telephony_usage | Should -HaveCount 4
        }

        It 'Should set PageSize to 300 automatically' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -CombineAllPages

            Should -Invoke Get-ZoomTelephoneReports -ModuleName PSZoom -ParameterFilter {
                $PageSize -eq 300
            }
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ telephony_usage = @() }
            }
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -PageSize 0 } | Should -Throw
            { Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -PageSize 301 } | Should -Throw
        }

        It 'Should accept valid PageSize within range' {
            { Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -PageSize 150 } | Should -Not -Throw
        }

        It 'Should only accept Type value of 1' {
            { Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -Type 1 } | Should -Not -Throw
            { Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -Type 2 } | Should -Throw
        }

        It 'Should accept parameter aliases' {
            Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' -size 100 -page 2

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100' -and $Uri -match 'page_number=2'
            }
        }
    }

    Context 'When handling date conversion' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ telephony_usage = @() }
            }
        }

        It 'Should convert DateTime objects to yyyy-MM-dd format' {
            $fromDate = Get-Date '2025-01-01'
            $toDate = Get-Date '2025-01-31'

            Get-ZoomTelephoneReports -From $fromDate -To $toDate

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'from=2025-01-01' -and $Uri -match 'to=2025-01-31'
            }
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Invalid date range'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomTelephoneReports -From '2025-01-01' -To '2025-01-31' } | Should -Throw
        }
    }
}
