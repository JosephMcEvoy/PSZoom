BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $script:MockResponse = Get-Content -Path "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-poll-get.json" -Raw | ConvertFrom-Json
}

Describe 'Get-ZoomWebinarPoll' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns webinar poll data' {
            $result = Get-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Get-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123'
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URI with webinar ID and poll ID' {
            Get-ZoomWebinarPoll -WebinarId 123456789 -PollId 'poll_xyz'
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*zoom.us/v2/webinars/123456789/polls/poll_xyz*'
            }
        }

        It 'Uses GET method' {
            Get-ZoomWebinarPoll -WebinarId 123456789 -PollId 'abc123'
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command Get-ZoomWebinarPoll).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Requires PollId parameter' {
            (Get-Command Get-ZoomWebinarPoll).Parameters['PollId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'WebinarId accepts int64 type' {
            (Get-Command Get-ZoomWebinarPoll).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }

        It 'PollId accepts string type' {
            (Get-Command Get-ZoomWebinarPoll).Parameters['PollId'].ParameterType.Name | Should -Be 'String'
        }

        It 'WebinarId has webinar_id alias' {
            (Get-Command Get-ZoomWebinarPoll).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'WebinarId has id alias' {
            (Get-Command Get-ZoomWebinarPoll).Parameters['WebinarId'].Aliases | Should -Contain 'id'
        }

        It 'PollId has poll_id alias' {
            (Get-Command Get-ZoomWebinarPoll).Parameters['PollId'].Aliases | Should -Contain 'poll_id'
        }
    }

    Context 'Positional Parameters' {
        It 'Accepts WebinarId at position 0' {
            $result = Get-ZoomWebinarPoll 123456789 'abc123'
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/123456789/polls/abc123*'
            }
        }

        It 'Accepts PollId at position 1' {
            $result = Get-ZoomWebinarPoll 987654321 'poll_test'
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/987654321/polls/poll_test*'
            }
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by property name' {
            $webinarObj = [PSCustomObject]@{ WebinarId = 123456789; PollId = 'abc123' }
            $webinarObj | Get-ZoomWebinarPoll
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/123456789/polls/abc123*'
            }
        }

        It 'Accepts id alias from pipeline by property name' {
            $webinarObj = [PSCustomObject]@{ id = 555666777; poll_id = 'test_poll' }
            $webinarObj | Get-ZoomWebinarPoll
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/555666777/polls/test_poll*'
            }
        }

        It 'Accepts WebinarId from pipeline by value' {
            123456789 | Get-ZoomWebinarPoll -PollId 'abc123'
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/123456789/polls/abc123*'
            }
        }

        It 'Processes multiple objects from pipeline' {
            $webinars = @(
                [PSCustomObject]@{ WebinarId = 111111111; PollId = 'poll1' },
                [PSCustomObject]@{ WebinarId = 222222222; PollId = 'poll2' }
            )
            $webinars | Get-ZoomWebinarPoll
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Throws error when WebinarId is missing' {
            { Get-ZoomWebinarPoll -PollId 'abc123' } | Should -Throw
        }

        It 'Throws error when PollId is missing' {
            { Get-ZoomWebinarPoll -WebinarId 123456789 } | Should -Throw
        }

        It 'Propagates API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Poll not found'
            }
            { Get-ZoomWebinarPoll -WebinarId 123456789 -PollId 'nonexistent' } | Should -Throw '*API Error*'
        }
    }
}
