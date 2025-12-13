BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'zoom.us'
    
    $fixtureFile = Join-Path $PSScriptRoot '../../../Fixtures/MockResponses/webinar-poll-post.json'
    if (Test-Path $fixtureFile) {
        $script:mockResponse = Get-Content -Path $fixtureFile -Raw | ConvertFrom-Json
    } else {
        $script:mockResponse = @{
            id = 'abc123'
            title = 'Test Poll'
            status = 'notstart'
            anonymous = $false
            poll_type = 1
            questions = @(
                @{
                    name = 'How would you rate this webinar?'
                    type = 'single'
                    answers = @('Excellent', 'Good', 'Average', 'Poor')
                }
            )
        }
    }
}

Describe 'New-ZoomWebinarPoll' {
    BeforeEach {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { $script:mockResponse }
    }
    
    Context 'Basic Functionality' {
        It 'Creates a webinar poll and returns response' {
            $questions = @(
                @{
                    name = 'How would you rate this webinar?'
                    type = 'single'
                    answers = @('Excellent', 'Good', 'Average', 'Poor')
                }
            )
            $result = New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions
            
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
        
        It 'Returns poll object with expected properties' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            $result = New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions
            
            $result.id | Should -Not -BeNullOrEmpty
            $result.title | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'API Endpoint Construction' {
        It 'Calls correct endpoint URL' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/123456789/polls'
            }
        }
        
        It 'Uses POST method' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }
        
        It 'Includes title in request body' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'My Custom Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"title"\s*:\s*"My Custom Poll"'
            }
        }
        
        It 'Includes questions in request body' {
            $questions = @(@{ name = 'Test Question?'; type = 'single'; answers = @('Yes', 'No') })
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"questions"'
            }
        }
    }
    
    Context 'Optional Parameters' {
        It 'Includes Anonymous parameter when specified' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions -Anonymous $true
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"anonymous"\s*:\s*true'
            }
        }
        
        It 'Includes PollType parameter when specified' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions -PollType 2
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"poll_type"\s*:\s*2'
            }
        }
        
        It 'Does not include Anonymous when not specified' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -notmatch '"anonymous"'
            }
        }
    }
    
    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command New-ZoomWebinarPoll).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }
        
        It 'Requires Title parameter' {
            (Get-Command New-ZoomWebinarPoll).Parameters['Title'].Attributes.Mandatory | Should -Contain $true
        }
        
        It 'Requires Questions parameter' {
            (Get-Command New-ZoomWebinarPoll).Parameters['Questions'].Attributes.Mandatory | Should -Contain $true
        }
        
        It 'Accepts webinar_id as alias for WebinarId' {
            (Get-Command New-ZoomWebinarPoll).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }
        
        It 'Accepts id as alias for WebinarId' {
            (Get-Command New-ZoomWebinarPoll).Parameters['WebinarId'].Aliases | Should -Contain 'id'
        }
        
        It 'Accepts poll_type as alias for PollType' {
            (Get-Command New-ZoomWebinarPoll).Parameters['PollType'].Aliases | Should -Contain 'poll_type'
        }
        
        It 'Validates PollType accepts value 1' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            { New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test' -Questions $questions -PollType 1 } | Should -Not -Throw
        }
        
        It 'Validates PollType accepts value 2' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            { New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test' -Questions $questions -PollType 2 } | Should -Not -Throw
        }
        
        It 'Validates PollType accepts value 3' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            { New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test' -Questions $questions -PollType 3 } | Should -Not -Throw
        }
        
        It 'Rejects invalid PollType value' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            { New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test' -Questions $questions -PollType 5 } | Should -Throw
        }
        
        It 'Validates Title maximum length of 64 characters' {
            $validateLength = (Get-Command New-ZoomWebinarPoll).Parameters['Title'].Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateLengthAttribute] }
            $validateLength.MaxLength | Should -Be 64
        }
    }
    
    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by property name' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            $webinarObj = [PSCustomObject]@{ WebinarId = 987654321 }
            $webinarObj | New-ZoomWebinarPoll -Title 'Pipeline Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/987654321/polls'
            }
        }
        
        It 'Accepts id from pipeline by property name via alias' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            $webinarObj = [PSCustomObject]@{ id = 555666777 }
            $webinarObj | New-ZoomWebinarPoll -Title 'Pipeline Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/555666777/polls'
            }
        }
        
        It 'Accepts WebinarId from pipeline by value' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            123456789 | New-ZoomWebinarPoll -Title 'Value Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/webinars/123456789/polls'
            }
        }
    }
    
    Context 'Multiple Questions Support' {
        It 'Handles multiple questions in array' {
            $questions = @(
                @{ name = 'Question 1?'; type = 'single'; answers = @('Yes', 'No') }
                @{ name = 'Question 2?'; type = 'multiple'; answers = @('A', 'B', 'C') }
                @{ name = 'Comments?'; type = 'long_answer' }
            )
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Multi-Question Poll' -Questions $questions
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
    
    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions -WhatIf
            
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
        
        It 'Has SupportsShouldProcess enabled' {
            (Get-Command New-ZoomWebinarPoll).Parameters.ContainsKey('WhatIf') | Should -BeTrue
        }
    }
    
    Context 'Error Handling' {
        It 'Propagates API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { throw 'API Error: Poll creation failed' }
            
            $questions = @(@{ name = 'Test?'; type = 'single'; answers = @('Yes', 'No') })
            { New-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test Poll' -Questions $questions } | Should -Throw '*API Error*'
        }
    }
}
