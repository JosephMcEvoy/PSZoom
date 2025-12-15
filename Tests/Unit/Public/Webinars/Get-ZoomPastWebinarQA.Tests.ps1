BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    
    $fixtureFile = "$PSScriptRoot/../../../Fixtures/MockResponses/past-webinar-qa-get.json"
    if (Test-Path $fixtureFile) {
        $script:mockResponse = Get-Content -Path $fixtureFile -Raw | ConvertFrom-Json
    } else {
        $script:mockResponse = @{
            id = 123456789
            uuid = 'abc123=='
            start_time = '2024-01-15T10:00:00Z'
            questions = @(
                @{
                    name = 'Test User'
                    email = 'test@example.com'
                    question_details = @(
                        @{
                            question = 'What is the main topic?'
                            answer = 'PowerShell automation'
                        }
                    )
                }
            )
        }
    }
}

Describe 'Get-ZoomPastWebinarQa' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { $script:mockResponse }
    }
    
    Context 'Basic Functionality' {
        It 'Returns Q&A data for a past webinar' {
            $result = Get-ZoomPastWebinarQa -WebinarId 123456789
            $result | Should -Not -BeNullOrEmpty
        }
        
        It 'Returns expected properties' {
            $result = Get-ZoomPastWebinarQa -WebinarId 123456789
            $result.id | Should -Be $script:mockResponse.id
        }
        
        It 'Returns questions array when present' {
            $result = Get-ZoomPastWebinarQa -WebinarId 123456789
            $result.questions | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'API Endpoint Construction' {
        It 'Calls correct API endpoint' {
            Get-ZoomPastWebinarQa -WebinarId 123456789
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/past_webinars/123456789/qa'
            }
        }
        
        It 'Handles URL-encoded webinar ID with special characters' {
            Get-ZoomPastWebinarQa -WebinarId 'abc123=='
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/past_webinars/'
            }
        }
        
        It 'Uses GET method' {
            Get-ZoomPastWebinarQa -WebinarId 123456789
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }
    }
    
    Context 'Parameter Validation' {
        It 'WebinarId parameter is mandatory' {
            (Get-Command Get-ZoomPastWebinarQa).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }
        
        It 'Accepts webinar_id as alias' {
            $result = Get-ZoomPastWebinarQa -webinar_id 123456789
            $result | Should -Not -BeNullOrEmpty
        }
        
        It 'Accepts id as alias' {
            $result = Get-ZoomPastWebinarQa -id 123456789
            $result | Should -Not -BeNullOrEmpty
        }
        
        It 'Accepts WebinarId as positional parameter' {
            $result = Get-ZoomPastWebinarQa 123456789
            $result | Should -Not -BeNullOrEmpty
        }
        
        It 'Accepts string WebinarId' {
            $result = Get-ZoomPastWebinarQa -WebinarId '123456789'
            $result | Should -Not -BeNullOrEmpty
        }
        
        It 'Accepts integer WebinarId' {
            $result = Get-ZoomPastWebinarQa -WebinarId 123456789
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by value' {
            $result = 123456789 | Get-ZoomPastWebinarQa
            $result | Should -Not -BeNullOrEmpty
        }
        
        It 'Accepts WebinarId from pipeline by property name' {
            $webinar = [PSCustomObject]@{ WebinarId = 123456789 }
            $result = $webinar | Get-ZoomPastWebinarQa
            $result | Should -Not -BeNullOrEmpty
        }
        
        It 'Accepts id alias from pipeline by property name' {
            $webinar = [PSCustomObject]@{ id = 123456789 }
            $result = $webinar | Get-ZoomPastWebinarQa
            $result | Should -Not -BeNullOrEmpty
        }
        
        It 'Processes multiple webinars from pipeline' {
            $webinars = @(
                [PSCustomObject]@{ WebinarId = 123456789 }
                [PSCustomObject]@{ WebinarId = 987654321 }
            )
            $webinars | Get-ZoomPastWebinarQa
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }
    
    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Webinar not found'
            }
            
            { Get-ZoomPastWebinarQa -WebinarId 999999999 } | Should -Throw
        }
        
        It 'Handles empty response' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { $null }
            
            $result = Get-ZoomPastWebinarQa -WebinarId 123456789
            $result | Should -BeNullOrEmpty
        }
        
        It 'Handles webinar with no Q&A' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                @{
                    id = 123456789
                    questions = @()
                }
            }
            
            $result = Get-ZoomPastWebinarQa -WebinarId 123456789
            $result.questions | Should -HaveCount 0
        }
    }
}
