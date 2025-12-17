BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomCalendar' {
    Context 'When retrieving calendar details' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'primary'
                    summary = 'Primary Calendar'
                    time_zone = 'America/New_York'
                    location = 'New York'
                    description = 'Main calendar'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI for primary calendar' {
            Get-ZoomCalendar -CalendarId 'primary'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/primary'
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI for specific calendar' {
            Get-ZoomCalendar -CalendarId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/abc123'
            }
        }

        It 'Should use GET method' {
            Get-ZoomCalendar -CalendarId 'primary'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return calendar object' {
            $result = Get-ZoomCalendar -CalendarId 'primary'
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'primary'
            $result.summary | Should -Be 'Primary Calendar'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'primary'
                    summary = 'Primary Calendar'
                }
            }
        }

        It 'Should accept CalendarId from pipeline' {
            'primary' | Get-ZoomCalendar
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with calendar_id property from pipeline' {
            [PSCustomObject]@{ calendar_id = 'abc123' } | Get-ZoomCalendar
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id property from pipeline' {
            [PSCustomObject]@{ id = 'abc123' } | Get-ZoomCalendar
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with cal_id property from pipeline' {
            [PSCustomObject]@{ cal_id = 'abc123' } | Get-ZoomCalendar
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'primary' }
            }
        }

        It 'Should accept cal_id alias for CalendarId' {
            { Get-ZoomCalendar -cal_id 'primary' } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias for CalendarId' {
            { Get-ZoomCalendar -calendar_id 'primary' } | Should -Not -Throw
        }

        It 'Should accept id alias for CalendarId' {
            { Get-ZoomCalendar -id 'primary' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'primary' }
            }
        }

        It 'Should accept CalendarId as first positional parameter' {
            $result = Get-ZoomCalendar 'primary'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Calendar not found')
            }

            { Get-ZoomCalendar -CalendarId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
