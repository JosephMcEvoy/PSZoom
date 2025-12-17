BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomSchedulerEventAttendee' {
    Context 'When getting an event attendee' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'attendee123'
                    email = 'attendee@example.com'
                    name = 'John Doe'
                    response_status = 'accepted'
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Get-ZoomSchedulerEventAttendee -EventId 'event123' -AttendeeId 'attendee123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/scheduler/events/event123/attendees/attendee123$'
            }
        }

        It 'Should use GET method' {
            Get-ZoomSchedulerEventAttendee -EventId 'event123' -AttendeeId 'attendee123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomSchedulerEventAttendee -EventId 'event123' -AttendeeId 'attendee123'

            $result.id | Should -Be 'attendee123'
            $result.email | Should -Be 'attendee@example.com'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'attendee123' }
            }
        }

        It 'Should accept EventId from pipeline' {
            'event123' | Get-ZoomSchedulerEventAttendee -AttendeeId 'attendee123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept event_id and attendee_id from pipeline by property name' {
            [PSCustomObject]@{
                event_id = 'event123'
                attendee_id = 'attendee123'
            } | Get-ZoomSchedulerEventAttendee

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'attendee123' }
            }
        }

        It 'Should accept event_id alias' {
            { Get-ZoomSchedulerEventAttendee -event_id 'event123' -attendee_id 'attendee123' } | Should -Not -Throw
        }
    }
}
