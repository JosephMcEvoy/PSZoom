BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomUserCalendarListEntry' {
    Context 'When updating a calendar list entry' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'abc123'
                    summary = 'Team Calendar'
                    color_id = '5'
                    selected = $true
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -ColorId '5' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/users/me/calendarList/abc123'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -ColorId '5' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'PATCH'
            }
        }

        It 'Should return updated calendar list entry object' {
            $result = Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -ColorId '5' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'abc123'
        }

        It 'Should include ColorId in request body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.color_id | Should -Be '3'
                return @{ id = 'abc123' }
            }

            Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -ColorId '3' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Hidden in request body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.hidden | Should -Be $true
                return @{ id = 'abc123' }
            }

            Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Hidden $true -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Selected in request body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.selected | Should -Be $false
                return @{ id = 'abc123' }
            }

            Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Selected $false -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should support -WhatIf parameter' {
            Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -ColorId '5' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support -Confirm parameter' {
            Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -ColorId '5' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have ConfirmImpact set to Low' {
            $cmd = Get-Command Update-ZoomUserCalendarListEntry
            $cmd.ConfirmImpact | Should -Be 'Low'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should accept UserIdentifier from pipeline' {
            'me' | Update-ZoomUserCalendarListEntry -CalendarId 'abc123' -ColorId '5' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with all properties from pipeline' {
            $obj = [PSCustomObject]@{
                user_identifier = 'me'
                calendar_id = 'abc123'
                color_id = '5'
                hidden = $false
                selected = $true
            }
            $obj | Update-ZoomUserCalendarListEntry -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should accept user_identifier alias for UserIdentifier' {
            { Update-ZoomUserCalendarListEntry -user_identifier 'me' -CalendarId 'abc123' -ColorId '5' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserIdentifier' {
            { Update-ZoomUserCalendarListEntry -user_id 'user123' -CalendarId 'abc123' -ColorId '5' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias for CalendarId' {
            { Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -calendar_id 'abc123' -ColorId '5' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept color_id alias for ColorId' {
            { Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -color_id '5' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should accept UserIdentifier as first positional parameter' {
            { Update-ZoomUserCalendarListEntry 'me' -CalendarId 'abc123' -ColorId '5' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept CalendarId as second positional parameter' {
            { Update-ZoomUserCalendarListEntry 'me' 'abc123' -ColorId '5' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Calendar not found')
            }

            { Update-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'nonexistent' -ColorId '5' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
