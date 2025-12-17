BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomSchedulerEvent' {
    Context 'When retrieving a scheduler event' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'event123'
                    title = 'Team Meeting'
                    start_time = '2024-01-15T10:00:00Z'
                    duration = 60
                }
            }
        }

        It 'Should return event details' {
            $result = Get-ZoomSchedulerEvent -EventId 'event123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return event with correct id' {
            $result = Get-ZoomSchedulerEvent -EventId 'event123'
            $result.id | Should -Be 'event123'
        }

        It 'Should return event with title' {
            $result = Get-ZoomSchedulerEvent -EventId 'event123'
            $result.title | Should -Be 'Team Meeting'
        }

        It 'Should return event with start_time' {
            $result = Get-ZoomSchedulerEvent -EventId 'event123'
            $result.start_time | Should -Be '2024-01-15T10:00:00Z'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct event endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/scheduler/events/event123'
                return @{}
            }

            Get-ZoomSchedulerEvent -EventId 'event123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{}
            }

            Get-ZoomSchedulerEvent -EventId 'event123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'event123'
                    title = 'Team Meeting'
                }
            }
        }

        It 'Should accept EventId from pipeline' {
            $result = 'event123' | Get-ZoomSchedulerEvent
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with event_id property from pipeline' {
            $eventObject = [PSCustomObject]@{ event_id = 'event123' }
            $result = $eventObject | Get-ZoomSchedulerEvent
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with id property from pipeline' {
            $eventObject = [PSCustomObject]@{ id = 'event123' }
            $result = $eventObject | Get-ZoomSchedulerEvent
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept event_id alias for EventId' {
            { Get-ZoomSchedulerEvent -event_id 'event123' } | Should -Not -Throw
        }

        It 'Should accept id alias for EventId' {
            { Get-ZoomSchedulerEvent -id 'event123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'event123'
                    title = 'Team Meeting'
                }
            }
        }

        It 'Should accept EventId as first positional parameter' {
            $result = Get-ZoomSchedulerEvent 'event123'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Event not found')
            }

            { Get-ZoomSchedulerEvent -EventId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
