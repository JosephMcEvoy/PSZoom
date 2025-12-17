BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomSchedulerEvent' {
    Context 'When updating a scheduler event' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'event123'
                    title = 'Updated Meeting'
                    status = 'confirmed'
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Update-ZoomSchedulerEvent -EventId 'event123' -Title 'Updated Meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/scheduler/events/event123$'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomSchedulerEvent -EventId 'event123' -Title 'Updated Meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'PATCH'
            }
        }

        It 'Should include title in request body when provided' {
            Update-ZoomSchedulerEvent -EventId 'event123' -Title 'Updated Meeting'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"title"' -and $Body -match 'Updated Meeting'
            }
        }

        It 'Should include description in request body when provided' {
            Update-ZoomSchedulerEvent -EventId 'event123' -Description 'Updated description'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"description"'
            }
        }

        It 'Should include start_time in request body when provided' {
            Update-ZoomSchedulerEvent -EventId 'event123' -StartTime '2024-01-15T10:00:00Z'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"start_time"'
            }
        }

        It 'Should include duration in request body when provided' {
            Update-ZoomSchedulerEvent -EventId 'event123' -Duration 60

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"duration"'
            }
        }

        It 'Should include status in request body when provided' {
            Update-ZoomSchedulerEvent -EventId 'event123' -Status 'cancelled'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"status"'
            }
        }

        It 'Should return the response object' {
            $result = Update-ZoomSchedulerEvent -EventId 'event123' -Title 'Updated Meeting'

            $result.title | Should -Be 'Updated Meeting'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'event123' }
            }
        }

        It 'Should accept EventId from pipeline' {
            'event123' | Update-ZoomSchedulerEvent -Title 'Test'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept event_id from pipeline by property name' {
            [PSCustomObject]@{ event_id = 'event123' } | Update-ZoomSchedulerEvent -Title 'Test'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'event123' }
            }
        }

        It 'Should accept event_id alias' {
            { Update-ZoomSchedulerEvent -event_id 'event123' -Title 'Test' } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Update-ZoomSchedulerEvent -id 'event123' -Title 'Test' } | Should -Not -Throw
        }
    }
}
