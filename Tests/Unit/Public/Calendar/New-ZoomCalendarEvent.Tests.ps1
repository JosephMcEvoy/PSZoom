BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomCalendarEvent' {
    Context 'When creating a calendar event' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'event123'
                    summary = 'Team Meeting'
                    start = @{ date_time = '2024-01-15T14:00:00Z' }
                    end = @{ date_time = '2024-01-15T15:00:00Z' }
                }
            }
        }

        It 'Should call API with correct endpoint' {
            New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Team Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/calendars/primary/events$'
            }
        }

        It 'Should use POST method' {
            New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Team Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should include summary in request body' {
            New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Team Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"summary"' -and $Body -match 'Team Meeting'
            }
        }

        It 'Should include start date_time in request body' {
            New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"start"' -and $Body -match '"date_time"'
            }
        }

        It 'Should include end date_time in request body' {
            New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"end"'
            }
        }

        It 'Should include description when provided' {
            New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z' -Description 'A team meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"description"'
            }
        }

        It 'Should include location when provided' {
            New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z' -Location 'Room A'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"location"'
            }
        }

        It 'Should return the response object' {
            $result = New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Team Meeting' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

            $result.id | Should -Be 'event123'
            $result.summary | Should -Be 'Team Meeting'
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'event123' }
            }
        }

        It 'Should support WhatIf' {
            New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Test' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z' -WhatIf

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
            'primary' | New-ZoomCalendarEvent -Summary 'Test' -StartDateTime '2024-01-15T14:00:00Z' -EndDateTime '2024-01-15T15:00:00Z'

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
            { New-ZoomCalendarEvent -cal_id 'primary' -Summary 'Test' -start '2024-01-15T14:00:00Z' -end '2024-01-15T15:00:00Z' } | Should -Not -Throw
        }

        It 'Should accept title alias for Summary' {
            { New-ZoomCalendarEvent -CalendarId 'primary' -title 'Test' -start '2024-01-15T14:00:00Z' -end '2024-01-15T15:00:00Z' } | Should -Not -Throw
        }

        It 'Should accept start alias for StartDateTime' {
            { New-ZoomCalendarEvent -CalendarId 'primary' -Summary 'Test' -start '2024-01-15T14:00:00Z' -end '2024-01-15T15:00:00Z' } | Should -Not -Throw
        }
    }
}
