BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    
    $mockResponsePath = "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-token-get.json"
    if (Test-Path $mockResponsePath) {
        $script:mockResponse = Get-Content -Path $mockResponsePath -Raw | ConvertFrom-Json
    } else {
        $script:mockResponse = @{
            token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock_token_payload.signature'
        }
    }
}

Describe 'Get-ZoomWebinarToken' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
            return $script:mockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns webinar token data' {
            $result = Get-ZoomWebinarToken -WebinarId '123456789'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns token property' {
            $result = Get-ZoomWebinarToken -WebinarId '123456789'
            $result.token | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Get-ZoomWebinarToken -WebinarId '123456789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct endpoint for webinar token' {
            Get-ZoomWebinarToken -WebinarId '123456789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/token'
            }
        }

        It 'Uses GET method' {
            Get-ZoomWebinarToken -WebinarId '123456789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Includes type parameter in query string when specified' {
            Get-ZoomWebinarToken -WebinarId '123456789' -Type 'closed_caption_token'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'type=closed_caption_token'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            { Get-ZoomWebinarToken } | Should -Throw
        }

        It 'Accepts webinar_id as alias for WebinarId' {
            Get-ZoomWebinarToken -webinar_id '123456789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/token'
            }
        }

        It 'Accepts id as alias for WebinarId' {
            Get-ZoomWebinarToken -id '123456789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/token'
            }
        }

        It 'Validates Type parameter accepts closed_caption_token' {
            { Get-ZoomWebinarToken -WebinarId '123456789' -Type 'closed_caption_token' } | Should -Not -Throw
        }

        It 'Rejects invalid Type parameter values' {
            { Get-ZoomWebinarToken -WebinarId '123456789' -Type 'invalid_type' } | Should -Throw
        }

        It 'Accepts token_type as alias for Type' {
            Get-ZoomWebinarToken -WebinarId '123456789' -token_type 'closed_caption_token'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'type=closed_caption_token'
            }
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by value' {
            $result = '123456789' | Get-ZoomWebinarToken
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts WebinarId from pipeline by property name' {
            $webinarObject = [PSCustomObject]@{ WebinarId = '123456789' }
            $result = $webinarObject | Get-ZoomWebinarToken
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts multiple webinar IDs from pipeline' {
            $webinarIds = @('111111111', '222222222', '333333333')
            $webinarIds | Get-ZoomWebinarToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Webinar not found'
            }
            { Get-ZoomWebinarToken -WebinarId '999999999' -ErrorAction Stop } | Should -Throw
        }

        It 'Handles empty response' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
            $result = Get-ZoomWebinarToken -WebinarId '123456789'
            $result | Should -BeNullOrEmpty
        }
    }
}
