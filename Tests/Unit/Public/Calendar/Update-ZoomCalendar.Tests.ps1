BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomCalendar' {
    Context 'When updating a calendar' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'cal123'
                    summary = 'Updated Calendar'
                    time_zone = 'America/Los_Angeles'
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Update-ZoomCalendar -CalendarId 'cal123' -Summary 'Updated Calendar'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/calendars/cal123$'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomCalendar -CalendarId 'cal123' -Summary 'Updated Calendar'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'PATCH'
            }
        }

        It 'Should include summary in request body when provided' {
            Update-ZoomCalendar -CalendarId 'cal123' -Summary 'Updated Calendar'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"summary"'
            }
        }

        It 'Should include description in request body when provided' {
            Update-ZoomCalendar -CalendarId 'cal123' -Description 'Updated description'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"description"'
            }
        }

        It 'Should include time_zone in request body when provided' {
            Update-ZoomCalendar -CalendarId 'cal123' -TimeZone 'America/Los_Angeles'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"time_zone"'
            }
        }

        It 'Should include location in request body when provided' {
            Update-ZoomCalendar -CalendarId 'cal123' -Location 'Conference Room'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"location"'
            }
        }

        It 'Should return the response object' {
            $result = Update-ZoomCalendar -CalendarId 'cal123' -Summary 'Updated Calendar'

            $result.summary | Should -Be 'Updated Calendar'
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'cal123' }
            }
        }

        It 'Should support WhatIf' {
            Update-ZoomCalendar -CalendarId 'cal123' -Summary 'Test' -WhatIf

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'cal123' }
            }
        }

        It 'Should accept CalendarId from pipeline' {
            'cal123' | Update-ZoomCalendar -Summary 'Test'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept calendar_id from pipeline by property name' {
            [PSCustomObject]@{ calendar_id = 'cal123' } | Update-ZoomCalendar -Summary 'Test'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'cal123' }
            }
        }

        It 'Should accept cal_id alias' {
            { Update-ZoomCalendar -cal_id 'cal123' -Summary 'Test' } | Should -Not -Throw
        }

        It 'Should accept title alias for Summary' {
            { Update-ZoomCalendar -CalendarId 'cal123' -title 'Test' } | Should -Not -Throw
        }

        It 'Should accept tz alias for TimeZone' {
            { Update-ZoomCalendar -CalendarId 'cal123' -tz 'UTC' } | Should -Not -Throw
        }
    }
}
