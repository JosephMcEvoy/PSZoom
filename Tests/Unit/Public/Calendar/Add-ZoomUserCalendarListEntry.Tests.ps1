BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomUserCalendarListEntry' {
    Context 'When adding a calendar to user list' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'abc123'
                    summary = 'Team Calendar'
                    selected = $true
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/users/me/calendarList'
            }
        }

        It 'Should use POST method' {
            Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return calendar list entry object' {
            $result = Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'abc123'
        }

        It 'Should include CalendarId in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.id | Should -Be 'abc123'
                return @{ id = 'abc123' }
            }

            Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should include ColorId in body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.color_id | Should -Be '5'
                return @{ id = 'abc123' }
            }

            Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -ColorId '5' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Hidden in body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.hidden | Should -Be $false
                return @{ id = 'abc123' }
            }

            Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Hidden $false -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Selected in body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.selected | Should -Be $true
                return @{ id = 'abc123' }
            }

            Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Selected $true -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should support -WhatIf parameter' {
            Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support -Confirm parameter' {
            Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have ConfirmImpact set to Low' {
            $cmd = Get-Command Add-ZoomUserCalendarListEntry
            $cmd.ConfirmImpact | Should -Be 'Low'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should accept UserIdentifier from pipeline' {
            'me' | Add-ZoomUserCalendarListEntry -CalendarId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with properties from pipeline' {
            $obj = [PSCustomObject]@{
                user_identifier = 'me'
                calendar_id = 'abc123'
                color_id = '5'
            }
            $obj | Add-ZoomUserCalendarListEntry -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should accept user_identifier alias for UserIdentifier' {
            { Add-ZoomUserCalendarListEntry -user_identifier 'me' -CalendarId 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias for CalendarId' {
            { Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -calendar_id 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept color_id alias for ColorId' {
            { Add-ZoomUserCalendarListEntry -UserIdentifier 'me' -CalendarId 'abc123' -color_id '5' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should accept UserIdentifier as first positional parameter' {
            { Add-ZoomUserCalendarListEntry 'me' -CalendarId 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept CalendarId as second positional parameter' {
            { Add-ZoomUserCalendarListEntry 'me' 'abc123' -Confirm:$false } | Should -Not -Throw
        }
    }
}
