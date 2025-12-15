BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'test-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    $script:MockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/past-webinar-poll-get.json" | ConvertFrom-Json
}

Describe 'Get-ZoomPastWebinarPoll' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns poll results for a past webinar' {
            $result = Get-ZoomPastWebinarPoll -WebinarId '123456789'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns expected data structure' {
            $result = Get-ZoomPastWebinarPoll -WebinarId '123456789'
            $result.id | Should -Be $script:MockResponse.id
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Get-ZoomPastWebinarPoll -WebinarId '123456789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct API endpoint' {
            Get-ZoomPastWebinarPoll -WebinarId '123456789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/past_webinars/123456789/polls'
            }
        }

        It 'Uses GET method' {
            Get-ZoomPastWebinarPoll -WebinarId '123456789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Handles webinar IDs with special characters' {
            Get-ZoomPastWebinarPoll -WebinarId '123+456/789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/past_webinars/'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Accepts WebinarId parameter' {
            { Get-ZoomPastWebinarPoll -WebinarId '123456789' } | Should -Not -Throw
        }

        It 'Accepts webinar_id alias' {
            { Get-ZoomPastWebinarPoll -webinar_id '123456789' } | Should -Not -Throw
        }

        It 'Accepts id alias' {
            { Get-ZoomPastWebinarPoll -id '123456789' } | Should -Not -Throw
        }

        It 'Requires WebinarId parameter' {
            { Get-ZoomPastWebinarPoll -WebinarId $null } | Should -Throw
        }

        It 'Does not accept empty WebinarId' {
            { Get-ZoomPastWebinarPoll -WebinarId '' } | Should -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by value' {
            $result = '123456789' | Get-ZoomPastWebinarPoll
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts WebinarId from pipeline by property name' {
            $webinar = [PSCustomObject]@{ WebinarId = '123456789' }
            $result = $webinar | Get-ZoomPastWebinarPoll
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts id alias from pipeline by property name' {
            $webinar = [PSCustomObject]@{ id = '123456789' }
            $result = $webinar | Get-ZoomPastWebinarPoll
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Processes multiple webinar IDs from pipeline' {
            $webinarIds = @('111111111', '222222222', '333333333')
            $webinarIds | Get-ZoomPastWebinarPoll
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error' }
            { Get-ZoomPastWebinarPoll -WebinarId '123456789' -ErrorAction Stop } | Should -Throw
        }

        It 'Handles webinar not found error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'Webinar not found' }
            { Get-ZoomPastWebinarPoll -WebinarId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }

        It 'Handles null response from API' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
            $result = Get-ZoomPastWebinarPoll -WebinarId '123456789'
            $result | Should -BeNullOrEmpty
        }
    }
}
