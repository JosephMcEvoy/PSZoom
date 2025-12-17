BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomCalendar' {
    Context 'When deleting a secondary calendar' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call API with correct endpoint' {
            Remove-ZoomCalendar -CalendarId 'cal123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/calendars/cal123$'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomCalendar -CalendarId 'cal123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should return true on successful deletion' {
            $result = Remove-ZoomCalendar -CalendarId 'cal123' -Confirm:$false

            $result | Should -Be $true
        }
    }

    Context 'When attempting to delete primary calendar' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should not call API when CalendarId is primary' {
            Remove-ZoomCalendar -CalendarId 'primary' -Confirm:$false -ErrorAction SilentlyContinue

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should write an error when CalendarId is primary' {
            { Remove-ZoomCalendar -CalendarId 'primary' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            Remove-ZoomCalendar -CalendarId 'cal123' -WhatIf

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm:$false' {
            Remove-ZoomCalendar -CalendarId 'cal123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept CalendarId from pipeline' {
            'cal123' | Remove-ZoomCalendar -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept cal_id from pipeline by property name' {
            [PSCustomObject]@{ cal_id = 'cal123' } | Remove-ZoomCalendar -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept cal_id alias' {
            { Remove-ZoomCalendar -cal_id 'cal123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias' {
            { Remove-ZoomCalendar -calendar_id 'cal123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Remove-ZoomCalendar -id 'cal123' -Confirm:$false } | Should -Not -Throw
        }
    }
}
