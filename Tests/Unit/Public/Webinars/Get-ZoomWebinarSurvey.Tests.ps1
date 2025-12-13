BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    
    $mockResponsePath = "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-survey-get.json"
    $script:MockResponse = Get-Content -Path $mockResponsePath -Raw | ConvertFrom-Json
}

Describe 'Get-ZoomWebinarSurvey' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns webinar survey data' {
            $result = Get-ZoomWebinarSurvey -WebinarId 123456789
            
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Get-ZoomWebinarSurvey -WebinarId 123456789
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URL for webinar survey' {
            Get-ZoomWebinarSurvey -WebinarId 123456789
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Uses GET method' {
            Get-ZoomWebinarSurvey -WebinarId 123456789
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Handles large webinar IDs correctly' {
            Get-ZoomWebinarSurvey -WebinarId 99999999999
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/99999999999/survey'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command Get-ZoomWebinarSurvey).Parameters['WebinarId'].Attributes.Mandatory | 
                Should -Contain $true
        }

        It 'WebinarId is of type Int64' {
            (Get-Command Get-ZoomWebinarSurvey).Parameters['WebinarId'].ParameterType.Name | 
                Should -Be 'Int64'
        }

        It 'Accepts webinar_id alias' {
            $aliases = (Get-Command Get-ZoomWebinarSurvey).Parameters['WebinarId'].Aliases
            $aliases | Should -Contain 'webinar_id'
        }

        It 'Accepts id alias' {
            $aliases = (Get-Command Get-ZoomWebinarSurvey).Parameters['WebinarId'].Aliases
            $aliases | Should -Contain 'id'
        }

        It 'Works with webinar_id alias parameter' {
            Get-ZoomWebinarSurvey -webinar_id 123456789
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Works with id alias parameter' {
            Get-ZoomWebinarSurvey -id 123456789
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by value' {
            $param = (Get-Command Get-ZoomWebinarSurvey).Parameters['WebinarId']
            $param.Attributes.ValueFromPipeline | Should -Contain $true
        }

        It 'Accepts WebinarId from pipeline by property name' {
            $param = (Get-Command Get-ZoomWebinarSurvey).Parameters['WebinarId']
            $param.Attributes.ValueFromPipelineByPropertyName | Should -Contain $true
        }

        It 'Processes single webinar ID from pipeline' {
            123456789 | Get-ZoomWebinarSurvey
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Processes multiple webinar IDs from pipeline' {
            @(111111111, 222222222, 333333333) | Get-ZoomWebinarSurvey
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3 -Exactly
        }

        It 'Processes object with WebinarId property from pipeline' {
            [PSCustomObject]@{ WebinarId = 123456789 } | Get-ZoomWebinarSurvey
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }
    }

    Context 'Error Handling' {
        It 'Throws error when WebinarId is not provided' {
            { Get-ZoomWebinarSurvey -WebinarId $null } | Should -Throw
        }

        It 'Propagates API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Webinar not found'
            }
            
            { Get-ZoomWebinarSurvey -WebinarId 123456789 } | Should -Throw '*API Error*'
        }

        It 'Handles webinar with no survey configured' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
            
            $result = Get-ZoomWebinarSurvey -WebinarId 123456789
            $result | Should -BeNullOrEmpty
        }
    }
}
