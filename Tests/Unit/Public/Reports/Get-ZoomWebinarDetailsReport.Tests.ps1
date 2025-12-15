BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinarDetailsReport' {
    Context 'When retrieving webinar details report' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    uuid = 'abc123'
                    id = 1234567890
                    type = 5
                    topic = 'Test Webinar'
                    user_name = 'Host User'
                    user_email = 'host@test.com'
                    start_time = '2025-01-15T10:00:00Z'
                    end_time = '2025-01-15T11:00:00Z'
                    duration = 60
                    total_participants = 100
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinarDetailsReport -WebinarId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/report/webinars/1234567890'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomWebinarDetailsReport } | Should -Throw
        }

        It 'Should accept WebinarId from pipeline by property name' {
            [PSCustomObject]@{ WebinarId = '1234567890' } | Get-ZoomWebinarDetailsReport

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept id alias for WebinarId' {
            Get-ZoomWebinarDetailsReport -id '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return the response object' {
            $result = Get-ZoomWebinarDetailsReport -WebinarId '1234567890'

            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 1234567890
            $result.topic | Should -Be 'Test Webinar'
        }

        It 'Should use GET method' {
            Get-ZoomWebinarDetailsReport -WebinarId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should handle multiple webinar IDs' {
            Get-ZoomWebinarDetailsReport -WebinarId '1234567890', '0987654321'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should call API once for each webinar ID' {
            Get-ZoomWebinarDetailsReport -WebinarId '1234567890', '0987654321'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Webinar not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomWebinarDetailsReport -WebinarId '1234567890' } | Should -Throw
        }
    }

    Context 'When validating parameter types' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 1234567890 }
            }
        }

        It 'Should accept WebinarId as string' {
            { Get-ZoomWebinarDetailsReport -WebinarId '1234567890' } | Should -Not -Throw
        }

        It 'Should accept array of WebinarIds' {
            { Get-ZoomWebinarDetailsReport -WebinarId @('1234567890', '0987654321') } | Should -Not -Throw
        }

        It 'Should process each WebinarId in array separately' {
            $webinarIds = @('1234567890', '0987654321', '1122334455')
            Get-ZoomWebinarDetailsReport -WebinarId $webinarIds

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }
    }
}
