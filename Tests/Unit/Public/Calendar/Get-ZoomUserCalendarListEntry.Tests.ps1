BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomUserCalendarListEntry' {
    Context 'When retrieving a specific calendar list entry' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'abc123'
                    summary = 'Team Calendar'
                    color_id = '5'
                    selected = $true
                    hidden = $false
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/users/me/calendarList/abc123'
            }
        }

        It 'Should use GET method' {
            Get-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return calendar list entry object' {
            $result = Get-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123'
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'abc123'
            $result.summary | Should -Be 'Team Calendar'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'abc123'
                    summary = 'Team Calendar'
                }
            }
        }

        It 'Should accept UserIdentifier from pipeline' {
            'me' | Get-ZoomUserCalendarListEntry -CalendarId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with both properties from pipeline' {
            $obj = [PSCustomObject]@{
                user_identifier = 'me'
                calendar_id = 'abc123'
            }
            $obj | Get-ZoomUserCalendarListEntry
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id alias from pipeline' {
            $obj = [PSCustomObject]@{
                user = 'me'
                id = 'abc123'
            }
            $obj | Get-ZoomUserCalendarListEntry
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'abc123' }
            }
        }

        It 'Should accept user_identifier alias for UserIdentifier' {
            { Get-ZoomUserCalendarListEntry -user_identifier 'me' -CalendarId 'abc123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserIdentifier' {
            { Get-ZoomUserCalendarListEntry -user_id 'user123' -CalendarId 'abc123' } | Should -Not -Throw
        }

        It 'Should accept user alias for UserIdentifier' {
            { Get-ZoomUserCalendarListEntry -user 'user@example.com' -CalendarId 'abc123' } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias for CalendarId' {
            { Get-ZoomUserCalendarListEntry -UserIdentifier 'me' -calendar_id 'abc123' } | Should -Not -Throw
        }

        It 'Should accept id alias for CalendarId' {
            { Get-ZoomUserCalendarListEntry -UserIdentifier 'me' -id 'abc123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'abc123' }
            }
        }

        It 'Should accept UserIdentifier as first positional parameter' {
            { Get-ZoomUserCalendarListEntry 'me' -CalendarId 'abc123' } | Should -Not -Throw
        }

        It 'Should accept CalendarId as second positional parameter' {
            { Get-ZoomUserCalendarListEntry 'me' 'abc123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Calendar not found')
            }

            { Get-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
