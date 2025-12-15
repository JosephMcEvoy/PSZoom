BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomWebinar' {
    Context 'When updating a webinar' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomWebinar -WebinarId 1234567890 -Topic 'Updated Topic'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890*'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomWebinar -WebinarId 1234567890 -Topic 'Updated Topic'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should require WebinarId parameter' {
            { Update-ZoomWebinar -Topic 'Test' } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Update-ZoomWebinar -Topic 'Test'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept webinar_id alias' {
            Update-ZoomWebinar -webinar_id 1234567890 -Topic 'Test'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include OccurrenceId in query when provided' {
            Update-ZoomWebinar -WebinarId 1234567890 -OccurrenceId 'occur123' -Topic 'Test'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'occurrence_id=occur123'
            }
        }

        It 'Should accept optional parameters' {
            { Update-ZoomWebinar -WebinarId 1234567890 -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' -Duration 60 } | Should -Not -Throw
        }
    }
}
