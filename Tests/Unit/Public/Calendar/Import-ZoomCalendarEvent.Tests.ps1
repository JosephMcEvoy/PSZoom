BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Import-ZoomCalendarEvent' {
    Context 'When importing a calendar event' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'event123'
                    summary = 'Imported Meeting'
                    start = @{ date_time = '2024-01-15T14:00:00Z' }
                    end = @{ date_time = '2024-01-15T15:00:00Z' }
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Imported Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/calendars/primary/events/import$'
            }
        }

        It 'Should use POST method' {
            Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Imported Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should include summary in request body' {
            Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Imported Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"summary"' -and $Body -match 'Imported Meeting'
            }
        }

        It 'Should include start and end in request body' {
            Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"start"' -and $Body -match '"end"'
            }
        }

        It 'Should include ical_uid when provided' {
            Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z' -ICalUID 'external-123@example.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"ical_uid"'
            }
        }

        It 'Should include description when provided' {
            Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z' -Description 'Imported from external calendar'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"description"'
            }
        }

        It 'Should include location when provided' {
            Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z' -Location 'Room B'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"location"'
            }
        }

        It 'Should return the response object' {
            $result = Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Imported Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            $result.id | Should -Be 'event123'
            $result.summary | Should -Be 'Imported Meeting'
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'event123' }
            }
        }

        It 'Should support WhatIf' {
            Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Test' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z' -WhatIf

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'event123' }
            }
        }

        It 'Should accept CalendarId from pipeline' {
            'primary' | Import-ZoomCalendarEvent -Summary 'Test' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'event123' }
            }
        }

        It 'Should accept cal_id alias' {
            { Import-ZoomCalendarEvent -cal_id 'primary' -Summary 'Test' -start '2024-01-15T14:00:00Z' -end '2024-01-15T15:00:00Z' } | Should -Not -Throw
        }

        It 'Should accept title alias for Summary' {
            { Import-ZoomCalendarEvent -CalendarId 'primary' -title 'Test' -start '2024-01-15T14:00:00Z' -end '2024-01-15T15:00:00Z' } | Should -Not -Throw
        }

        It 'Should accept ical_uid alias for ICalUID' {
            { Import-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Test' -start '2024-01-15T14:00:00Z' -end '2024-01-15T15:00:00Z' -ical_uid 'test@example.com' } | Should -Not -Throw
        }
    }
}
