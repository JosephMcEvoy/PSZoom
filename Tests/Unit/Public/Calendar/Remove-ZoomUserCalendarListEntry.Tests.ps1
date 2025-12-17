BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomUserCalendarListEntry' {
    Context 'When removing a calendar from user list' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/users/me/calendarList/abc123'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should return true on success' {
            $result = Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            $result | Should -Be $true
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should support -WhatIf parameter' {
            Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support -Confirm parameter' {
            Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have ConfirmImpact set to High' {
            $cmd = Get-Command Remove-ZoomUserCalendarListEntry
            $cmd.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept UserIdentifier from pipeline' {
            'me' | Remove-ZoomUserCalendarListEntry -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with both properties from pipeline' {
            $obj = [PSCustomObject]@{
                user_identifier = 'me'
                calendar_id = 'abc123'
            }
            $obj | Remove-ZoomUserCalendarListEntry -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id alias from pipeline' {
            $obj = [PSCustomObject]@{
                user = 'me'
                id = 'abc123'
            }
            $obj | Remove-ZoomUserCalendarListEntry -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept user_identifier alias for UserIdentifier' {
            { Remove-ZoomUserCalendarListEntry -user_identifier 'me' -CalendarId 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserIdentifier' {
            { Remove-ZoomUserCalendarListEntry -user_id 'user123' -CalendarId 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept user alias for UserIdentifier' {
            { Remove-ZoomUserCalendarListEntry -user 'user@example.com' -CalendarId 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias for CalendarId' {
            { Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -calendar_id 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias for CalendarId' {
            { Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -id 'abc123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept UserIdentifier as first positional parameter' {
            { Remove-ZoomUserCalendarListEntry 'me' -CalendarId 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept CalendarId as second positional parameter' {
            { Remove-ZoomUserCalendarListEntry 'me' 'abc123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Calendar not found')
            }

            { Remove-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'nonexistent' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
