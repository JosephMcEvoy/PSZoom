BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'zoom.us'
    
    $fixtureFile = "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-tracking-source-get.json"
    if (Test-Path $fixtureFile) {
        $script:mockResponse = Get-Content -Path $fixtureFile -Raw | ConvertFrom-Json
    } else {
        $script:mockResponse = @{
            total_records = 2
            tracking_sources = @(
                @{
                    id = 'abc123'
                    source_name = 'Facebook'
                    tracking_url = 'https://zoom.us/webinar/register/abc123?tk=facebook'
                    visitor_count = 150
                    registration_count = 45
                }
                @{
                    id = 'def456'
                    source_name = 'LinkedIn'
                    tracking_url = 'https://zoom.us/webinar/register/abc123?tk=linkedin'
                    visitor_count = 200
                    registration_count = 60
                }
            )
        }
    }
}

Describe 'Get-ZoomWebinarTrackingSource' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { $script:mockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns tracking sources data' {
            $result = Get-ZoomWebinarTrackingSource -WebinarId 123456789
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns expected tracking sources structure' {
            $result = Get-ZoomWebinarTrackingSource -WebinarId 123456789
            $result.tracking_sources | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Get-ZoomWebinarTrackingSource -WebinarId 123456789
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct endpoint URL' {
            Get-ZoomWebinarTrackingSource -WebinarId 123456789
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'https://api\.zoom\.us/v2/webinars/123456789/tracking_sources'
            }
        }

        It 'Uses GET method' {
            Get-ZoomWebinarTrackingSource -WebinarId 123456789
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Handles different webinar IDs correctly' {
            Get-ZoomWebinarTrackingSource -WebinarId 987654321
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'https://api\.zoom\.us/v2/webinars/987654321/tracking_sources'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command Get-ZoomWebinarTrackingSource).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'WebinarId accepts int64 type' {
            (Get-Command Get-ZoomWebinarTrackingSource).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }

        It 'WebinarId has alias webinar_id' {
            (Get-Command Get-ZoomWebinarTrackingSource).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'WebinarId has alias id' {
            (Get-Command Get-ZoomWebinarTrackingSource).Parameters['WebinarId'].Aliases | Should -Contain 'id'
        }

        It 'Accepts WebinarId at position 0' {
            { Get-ZoomWebinarTrackingSource 123456789 } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by value' {
            { 123456789 | Get-ZoomWebinarTrackingSource } | Should -Not -Throw
        }

        It 'Accepts WebinarId from pipeline by property name' {
            $webinarObject = [PSCustomObject]@{ WebinarId = 123456789 }
            { $webinarObject | Get-ZoomWebinarTrackingSource } | Should -Not -Throw
        }

        It 'Accepts id alias from pipeline by property name' {
            $webinarObject = [PSCustomObject]@{ id = 123456789 }
            { $webinarObject | Get-ZoomWebinarTrackingSource } | Should -Not -Throw
        }

        It 'Accepts webinar_id alias from pipeline by property name' {
            $webinarObject = [PSCustomObject]@{ webinar_id = 123456789 }
            { $webinarObject | Get-ZoomWebinarTrackingSource } | Should -Not -Throw
        }

        It 'Processes multiple webinars from pipeline' {
            $webinarIds = @(111111111, 222222222, 333333333)
            $webinarIds | Get-ZoomWebinarTrackingSource
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Throws error when WebinarId is not provided' {
            { Get-ZoomWebinarTrackingSource -WebinarId $null } | Should -Throw
        }

        It 'Propagates API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { throw 'API Error: Webinar not found' }
            { Get-ZoomWebinarTrackingSource -WebinarId 123456789 } | Should -Throw '*API Error*'
        }

        It 'Handles unauthorized access error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { throw 'Unauthorized: Invalid token' }
            { Get-ZoomWebinarTrackingSource -WebinarId 123456789 } | Should -Throw '*Unauthorized*'
        }
    }
}
