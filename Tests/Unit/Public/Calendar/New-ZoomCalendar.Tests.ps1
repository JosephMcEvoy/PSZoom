BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomCalendar' {
    Context 'When creating a secondary calendar' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'cal123'
                    summary = 'Project X Calendar'
                    time_zone = 'America/New_York'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomCalendar -Summary 'Project X Calendar' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars'
            }
        }

        It 'Should use POST method' {
            New-ZoomCalendar -Summary 'Project X Calendar' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return calendar object' {
            $result = New-ZoomCalendar -Summary 'Project X Calendar' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'cal123'
            $result.summary | Should -Be 'Project X Calendar'
        }

        It 'Should include Summary in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.summary | Should -Be 'Team Calendar'
                return @{ id = 'cal123' }
            }

            New-ZoomCalendar -Summary 'Team Calendar' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'cal123' } }
        }

        It 'Should include Description in body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.description | Should -Be 'Team events calendar'
                return @{ id = 'cal123' }
            }

            New-ZoomCalendar -Summary 'Team Calendar' -Description 'Team events calendar' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include TimeZone in body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.time_zone | Should -Be 'America/Los_Angeles'
                return @{ id = 'cal123' }
            }

            New-ZoomCalendar -Summary 'Team Calendar' -TimeZone 'America/Los_Angeles' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Location in body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.location | Should -Be 'San Francisco Office'
                return @{ id = 'cal123' }
            }

            New-ZoomCalendar -Summary 'Team Calendar' -Location 'San Francisco Office' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'cal123' } }
        }

        It 'Should support -WhatIf parameter' {
            New-ZoomCalendar -Summary 'Project X Calendar' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support -Confirm parameter' {
            New-ZoomCalendar -Summary 'Project X Calendar' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have ConfirmImpact set to Low' {
            $cmd = Get-Command New-ZoomCalendar
            $cmd.ConfirmImpact | Should -Be 'Low'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'cal123' } }
        }

        It 'Should accept Summary from pipeline' {
            'Project X Calendar' | New-ZoomCalendar -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with properties from pipeline' {
            $obj = [PSCustomObject]@{
                summary = 'Team Calendar'
                description = 'Team events'
                time_zone = 'America/New_York'
                location = 'NYC Office'
            }
            $obj | New-ZoomCalendar -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'cal123' } }
        }

        It 'Should accept title alias for Summary' {
            { New-ZoomCalendar -title 'Test Calendar' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept name alias for Summary' {
            { New-ZoomCalendar -name 'Test Calendar' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept time_zone alias for TimeZone' {
            { New-ZoomCalendar -Summary 'Test' -time_zone 'UTC' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept tz alias for TimeZone' {
            { New-ZoomCalendar -Summary 'Test' -tz 'UTC' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'cal123' } }
        }

        It 'Should accept Summary as first positional parameter' {
            { New-ZoomCalendar 'Project X Calendar' -Confirm:$false } | Should -Not -Throw
        }
    }
}
