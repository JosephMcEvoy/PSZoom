BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomSchedulerSchedule' {
    Context 'When creating a scheduler schedule' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'schedule123'
                    name = 'Standard Meeting'
                    type = 'meeting'
                }
            }
        }

        It 'Should call API with correct endpoint' {
            New-ZoomSchedulerSchedule -Name 'Standard Meeting' -Type 'meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/scheduler/schedules$'
            }
        }

        It 'Should use POST method' {
            New-ZoomSchedulerSchedule -Name 'Standard Meeting' -Type 'meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should include name in request body' {
            New-ZoomSchedulerSchedule -Name 'Standard Meeting' -Type 'meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"name"' -and $Body -match 'Standard Meeting'
            }
        }

        It 'Should include type in request body' {
            New-ZoomSchedulerSchedule -Name 'Standard Meeting' -Type 'meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"type"' -and $Body -match '"meeting"'
            }
        }

        It 'Should include description when provided' {
            New-ZoomSchedulerSchedule -Name 'Meeting' -Type 'meeting' -Description 'A standard meeting template'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"description"'
            }
        }

        It 'Should include duration when provided' {
            New-ZoomSchedulerSchedule -Name 'Meeting' -Type 'meeting' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"duration"'
            }
        }

        It 'Should not include optional parameters when not provided' {
            New-ZoomSchedulerSchedule -Name 'Meeting' -Type 'meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -notmatch '"description"' -and $Body -notmatch '"duration"'
            }
        }

        It 'Should return the response object' {
            $result = New-ZoomSchedulerSchedule -Name 'Standard Meeting' -Type 'meeting'

            $result.id | Should -Be 'schedule123'
            $result.name | Should -Be 'Standard Meeting'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'schedule123' }
            }
        }

        It 'Should accept name and type from pipeline by property name' {
            [PSCustomObject]@{
                name = 'Test Schedule'
                type = 'meeting'
            } | New-ZoomSchedulerSchedule

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'schedule123' }
            }
        }

        It 'Should accept schedule_name alias' {
            { New-ZoomSchedulerSchedule -schedule_name 'Test' -Type 'meeting' } | Should -Not -Throw
        }

        It 'Should accept event_duration alias' {
            { New-ZoomSchedulerSchedule -Name 'Test' -Type 'meeting' -event_duration 30 } | Should -Not -Throw
        }
    }
}
