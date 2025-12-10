BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinar' {
    Context 'When retrieving webinar details' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    uuid = 'abc123xyz'
                    id = 1234567890
                    host_id = 'host123'
                    topic = 'Test Webinar'
                    type = 5
                    start_time = '2025-01-15T10:00:00Z'
                    duration = 60
                    timezone = 'America/Los_Angeles'
                    agenda = 'Webinar agenda'
                    created_at = '2025-01-01T10:00:00Z'
                    start_url = 'https://zoom.us/s/123456'
                    join_url = 'https://zoom.us/j/123456'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinar -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890*'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomWebinar } | Should -Throw
        }

        It 'Should accept WebinarId from pipeline' {
            1234567890 | Get-ZoomWebinar

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept webinar_id alias' {
            Get-ZoomWebinar -webinar_id 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include OccurrenceId in query when provided' {
            Get-ZoomWebinar -WebinarId 1234567890 -OccurrenceId 'occur123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'OccurrenceId=occur123'
            }
        }

        It 'Should accept ocurrence_id alias for OccurrenceId' {
            Get-ZoomWebinar -WebinarId 1234567890 -ocurrence_id 'occur123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'OccurrenceId=occur123'
            }
        }


        It 'Should use GET method' {
            Get-ZoomWebinar -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomWebinar -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 1234567890
            $result.topic | Should -Be 'Test Webinar'
            $result.type | Should -Be 5
        }

        It 'Should return webinar details with all expected properties' {
            $result = Get-ZoomWebinar -WebinarId 1234567890

            $result.uuid | Should -Be 'abc123xyz'
            $result.host_id | Should -Be 'host123'
            $result.start_time | Should -Be '2025-01-15T10:00:00Z'
            $result.duration | Should -Be 60
            $result.timezone | Should -Be 'America/Los_Angeles'
        }
    }

    Context 'When validating parameter types' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 1234567890 }
            }
        }

        It 'Should accept WebinarId as int64' {
            { Get-ZoomWebinar -WebinarId 1234567890 } | Should -Not -Throw
        }

        It 'Should accept large WebinarId values' {
            $largeId = [int64]9999999999
            { Get-ZoomWebinar -WebinarId $largeId } | Should -Not -Throw
        }

        It 'Should accept OccurrenceId as string' {
            { Get-ZoomWebinar -WebinarId 1234567890 -OccurrenceId 'occurrence123' } | Should -Not -Throw
        }

    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Webinar not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomWebinar -WebinarId 1234567890 } | Should -Throw
        }
    }

    Context 'When retrieving recurring webinar occurrences' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 1234567890
                    topic = 'Recurring Webinar'
                    type = 9
                    occurrences = @(
                        @{
                            occurrence_id = 'occur1'
                            start_time = '2025-01-15T10:00:00Z'
                            duration = 60
                        }
                        @{
                            occurrence_id = 'occur2'
                            start_time = '2025-01-22T10:00:00Z'
                            duration = 60
                        }
                    )
                }
            }
        }

        It 'Should retrieve specific occurrence when OccurrenceId is provided' {
            Get-ZoomWebinar -WebinarId 1234567890 -OccurrenceId 'occur1'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'OccurrenceId=occur1'
            }
        }

    }

    Context 'When constructing API endpoint' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 1234567890 }
            }
        }

        It 'Should construct correct base URI' {
            Get-ZoomWebinar -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890*'
            }
        }

        It 'Should not include query parameters when not provided' {
            Get-ZoomWebinar -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -notmatch 'OccurrenceId=' -and $Uri -notmatch 'show_previous_occurrences='
            }
        }
    }
}
