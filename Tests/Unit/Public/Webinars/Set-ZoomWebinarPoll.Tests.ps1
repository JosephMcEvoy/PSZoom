BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    $script:MockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/w-e-b-i-n-a-r-p-o-l-l-put.json" -Raw | ConvertFrom-Json
}

Describe 'Set-ZoomWebinarPoll' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns poll data when updating with title' {
            $result = Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Title 'Updated Poll'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns poll data when updating with anonymous setting' {
            $result = Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Anonymous $true
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns poll data when updating with poll type' {
            $result = Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -PollType 2
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns poll data when updating with questions' {
            $questions = @(
                @{
                    name = 'Updated Question'
                    type = 'single'
                    answers = @('Answer A', 'Answer B')
                }
            )
            $result = Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Questions $questions
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API Endpoint Construction' {
        It 'Calls correct endpoint for webinar poll update' {
            Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Title 'Test'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/polls/abc123'
            }
        }

        It 'Uses PUT method' {
            Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Title 'Test'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'PUT'
            }
        }

        It 'Includes title in request body when specified' {
            Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Title 'My Poll Title'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"title":\s*"My Poll Title"'
            }
        }

        It 'Includes anonymous in request body when specified' {
            Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Anonymous $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"anonymous":\s*true'
            }
        }

        It 'Includes poll_type in request body when specified' {
            Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -PollType 3
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"poll_type":\s*3'
            }
        }

        It 'Includes questions in request body when specified' {
            $questions = @(
                @{
                    name = 'Test Question'
                    type = 'single'
                    answers = @('Yes', 'No')
                }
            )
            Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Questions $questions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"questions":'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Requires PollId parameter' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['PollId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Has webinar_id alias for WebinarId parameter' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'Has id alias for WebinarId parameter' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['WebinarId'].Aliases | Should -Contain 'id'
        }

        It 'Has poll_id alias for PollId parameter' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['PollId'].Aliases | Should -Contain 'poll_id'
        }

        It 'Has poll_type alias for PollType parameter' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['PollType'].Aliases | Should -Contain 'poll_type'
        }

        It 'WebinarId accepts Int64 type' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }

        It 'PollId accepts String type' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['PollId'].ParameterType.Name | Should -Be 'String'
        }

        It 'Title accepts String type' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['Title'].ParameterType.Name | Should -Be 'String'
        }

        It 'Anonymous accepts Boolean type' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['Anonymous'].ParameterType.Name | Should -Be 'Boolean'
        }

        It 'PollType accepts Int32 type' {
            (Get-Command Set-ZoomWebinarPoll).Parameters['PollType'].ParameterType.Name | Should -Be 'Int32'
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by property name' {
            $input = [PSCustomObject]@{ WebinarId = 123456789; PollId = 'abc123'; Title = 'Pipeline Test' }
            $result = $input | Set-ZoomWebinarPoll
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts webinar_id alias from pipeline by property name' {
            $input = [PSCustomObject]@{ webinar_id = 123456789; poll_id = 'abc123'; Title = 'Alias Test' }
            $result = $input | Set-ZoomWebinarPoll
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Processes multiple pipeline objects' {
            $inputs = @(
                [PSCustomObject]@{ WebinarId = 111111111; PollId = 'poll1'; Title = 'Poll 1' }
                [PSCustomObject]@{ WebinarId = 222222222; PollId = 'poll2'; Title = 'Poll 2' }
            )
            $results = $inputs | Set-ZoomWebinarPoll
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Error Handling' {
        It 'Throws when WebinarId is missing' {
            { Set-ZoomWebinarPoll -PollId 'abc123' -Title 'Test' } | Should -Throw
        }

        It 'Throws when PollId is missing' {
            { Set-ZoomWebinarPoll -WebinarId 123456789 -Title 'Test' } | Should -Throw
        }

        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { throw 'API Error' }
            { Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Title 'Test' } | Should -Throw
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            (Get-Command Set-ZoomWebinarPoll).Parameters.ContainsKey('WhatIf') | Should -BeTrue
        }

        It 'Supports Confirm parameter' {
            (Get-Command Set-ZoomWebinarPoll).Parameters.ContainsKey('Confirm') | Should -BeTrue
        }

        It 'Does not call API when WhatIf is specified' {
            Set-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123' -Title 'WhatIf Test' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }
}
