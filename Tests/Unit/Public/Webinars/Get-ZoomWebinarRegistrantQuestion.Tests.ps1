BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $script:MockResponse = Get-Content -Path $PSScriptRoot/../../../Fixtures/MockResponses/webinar-registrant-question-get.json -Raw | ConvertFrom-Json
}

Describe 'Get-ZoomWebinarRegistrantQuestion' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns registration questions data' {
            $result = Get-ZoomWebinarRegistrantQuestion -WebinarId 123456789
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Get-ZoomWebinarRegistrantQuestion -WebinarId 123456789
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs the correct API endpoint' {
            Get-ZoomWebinarRegistrantQuestion -WebinarId 123456789
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/123456789/registrants/questions'
            }
        }

        It 'Uses GET method' {
            Get-ZoomWebinarRegistrantQuestion -WebinarId 123456789
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Handles large webinar IDs correctly' {
            Get-ZoomWebinarRegistrantQuestion -WebinarId 99999999999
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/99999999999/registrants/questions'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command Get-ZoomWebinarRegistrantQuestion).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $True
        }

        It 'Accepts webinar_id alias' {
            Get-ZoomWebinarRegistrantQuestion -webinar_id 123456789
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/123456789/registrants/questions'
            }
        }

        It 'Accepts id alias' {
            Get-ZoomWebinarRegistrantQuestion -id 123456789
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/123456789/registrants/questions'
            }
        }

        It 'Accepts positional parameter' {
            Get-ZoomWebinarRegistrantQuestion 123456789
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/123456789/registrants/questions'
            }
        }

        It 'Has int64 type for WebinarId' {
            (Get-Command Get-ZoomWebinarRegistrantQuestion).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by value' {
            $result = 123456789 | Get-ZoomWebinarRegistrantQuestion
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts WebinarId from pipeline by property name' {
            $webinarObj = [PSCustomObject]@{ WebinarId = 123456789 }
            $result = $webinarObj | Get-ZoomWebinarRegistrantQuestion
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts id property from pipeline' {
            $webinarObj = [PSCustomObject]@{ id = 123456789 }
            $result = $webinarObj | Get-ZoomWebinarRegistrantQuestion
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Processes multiple webinars from pipeline' {
            $webinarIds = @(111111111, 222222222, 333333333)
            $webinarIds | Get-ZoomWebinarRegistrantQuestion
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Throws error when WebinarId is missing' {
            { Get-ZoomWebinarRegistrantQuestion -WebinarId $null } | Should -Throw
        }

        It 'Propagates API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error: Webinar not found' }
            { Get-ZoomWebinarRegistrantQuestion -WebinarId 123456789 } | Should -Throw '*API Error*'
        }

        It 'Handles invalid webinar ID gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'Invalid webinar ID' }
            { Get-ZoomWebinarRegistrantQuestion -WebinarId 0 } | Should -Throw
        }
    }

    Context 'Response Handling' {
        It 'Returns response object with expected structure' {
            $result = Get-ZoomWebinarRegistrantQuestion -WebinarId 123456789
            $result | Should -BeOfType [PSCustomObject]
        }

        It 'Passes through API response unchanged' {
            $result = Get-ZoomWebinarRegistrantQuestion -WebinarId 123456789
            $result | Should -Be $script:MockResponse
        }
    }
}
