BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomCalendarEvents' {
    Context 'When listing calendar events' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    items = @(
                        @{ id = 'event1'; summary = 'Event One' },
                        @{ id = 'event2'; summary = 'Event Two' }
                    )
                    next_page_token = ''
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Get-ZoomCalendarEvents -CalendarId 'primary'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/calendars/primary/events'
            }
        }

        It 'Should use GET method' {
            Get-ZoomCalendarEvents -CalendarId 'primary'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomCalendarEvents -CalendarId 'primary'

            $result.items.Count | Should -Be 2
        }
    }

    Context 'When using filter parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ items = @() }
            }
        }

        It 'Should include time_min in query when provided' {
            Get-ZoomCalendarEvents -CalendarId 'primary' -TimeMin '2024-01-01T00:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'time_min='
            }
        }

        It 'Should include time_max in query when provided' {
            Get-ZoomCalendarEvents -CalendarId 'primary' -TimeMax '2024-12-31T23:59:59Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'time_max='
            }
        }

        It 'Should include max_results in query when provided' {
            Get-ZoomCalendarEvents -CalendarId 'primary' -MaxResults 50

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'max_results=50'
            }
        }

        It 'Should include page_token in query when provided' {
            Get-ZoomCalendarEvents -CalendarId 'primary' -PageToken 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_token=token123'
            }
        }

        It 'Should include single_events in query when provided' {
            Get-ZoomCalendarEvents -CalendarId 'primary' -SingleEvents $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'single_events=true'
            }
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ items = @() }
            }
        }

        It 'Should accept CalendarId from pipeline' {
            'primary' | Get-ZoomCalendarEvents

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept cal_id from pipeline by property name' {
            [PSCustomObject]@{ cal_id = 'cal123' } | Get-ZoomCalendarEvents

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ items = @() }
            }
        }

        It 'Should accept cal_id alias' {
            { Get-ZoomCalendarEvents -cal_id 'primary' } | Should -Not -Throw
        }

        It 'Should accept time_min alias for TimeMin' {
            { Get-ZoomCalendarEvents -CalendarId 'primary' -time_min '2024-01-01T00:00:00Z' } | Should -Not -Throw
        }

        It 'Should accept max_results alias for MaxResults' {
            { Get-ZoomCalendarEvents -CalendarId 'primary' -max_results 50 } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should enforce MaxResults range (1-2500)' {
            { Get-ZoomCalendarEvents -CalendarId 'primary' -MaxResults 0 } | Should -Throw
            { Get-ZoomCalendarEvents -CalendarId 'primary' -MaxResults 2501 } | Should -Throw
        }
    }
}
