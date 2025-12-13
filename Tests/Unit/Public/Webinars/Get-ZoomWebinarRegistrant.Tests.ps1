BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $script:MockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/w-e-b-i-n-a-r-r-e-g-i-s-t-r-a-n-t-get.json" -Raw | ConvertFrom-Json
}

Describe 'Get-ZoomWebinarRegistrant' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns webinar registrant data' {
            $result = Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { $script:MockResponse }
            Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct base URL with webinar ID and registrant ID' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/123456789/registrants/abc123xyz*'
            } { $script:MockResponse }

            Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/123456789/registrants/abc123xyz*'
            } -Times 1 -Exactly
        }

        It 'Uses GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            } { $script:MockResponse }

            Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            } -Times 1 -Exactly
        }

        It 'Includes occurrence_id query parameter when specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*occurrence_id=1648194360000*'
            } { $script:MockResponse }

            Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz' -OccurrenceId '1648194360000'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*occurrence_id=1648194360000*'
            } -Times 1 -Exactly
        }

        It 'Does not include occurrence_id when not specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -notlike '*occurrence_id*'
            } { $script:MockResponse }

            Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -notlike '*occurrence_id*'
            } -Times 1 -Exactly
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Requires RegistrantId parameter' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['RegistrantId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Does not require OccurrenceId parameter' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['OccurrenceId'].Attributes.Mandatory | Should -Not -Contain $true
        }

        It 'Accepts webinar_id as alias for WebinarId' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'Accepts registrant_id as alias for RegistrantId' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['RegistrantId'].Aliases | Should -Contain 'registrant_id'
        }

        It 'Accepts id as alias for RegistrantId' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['RegistrantId'].Aliases | Should -Contain 'id'
        }

        It 'Accepts occurrence_id as alias for OccurrenceId' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['OccurrenceId'].Aliases | Should -Contain 'occurrence_id'
        }

        It 'WebinarId is int64 type' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }

        It 'RegistrantId is string type' {
            (Get-Command Get-ZoomWebinarRegistrant).Parameters['RegistrantId'].ParameterType.Name | Should -Be 'String'
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { $script:MockResponse }
            { 123456789 | Get-ZoomWebinarRegistrant -RegistrantId 'abc123xyz' } | Should -Not -Throw
        }

        It 'Accepts WebinarId from pipeline by property name' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { $script:MockResponse }
            $pipelineInput = [PSCustomObject]@{ WebinarId = 123456789; RegistrantId = 'abc123xyz' }
            { $pipelineInput | Get-ZoomWebinarRegistrant } | Should -Not -Throw
        }

        It 'Accepts RegistrantId from pipeline by property name' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { $script:MockResponse }
            $pipelineInput = [PSCustomObject]@{ WebinarId = 123456789; id = 'abc123xyz' }
            { $pipelineInput | Get-ZoomWebinarRegistrant } | Should -Not -Throw
        }

        It 'Processes multiple pipeline inputs' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { $script:MockResponse }
            $pipelineInputs = @(
                [PSCustomObject]@{ WebinarId = 123456789; RegistrantId = 'abc123' }
                [PSCustomObject]@{ WebinarId = 123456789; RegistrantId = 'xyz789' }
            )
            $pipelineInputs | Get-ZoomWebinarRegistrant
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Throws when API returns error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error' }
            { Get-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abc123xyz' } | Should -Throw
        }

        It 'Throws when WebinarId is missing' {
            { Get-ZoomWebinarRegistrant -RegistrantId 'abc123xyz' } | Should -Throw
        }

        It 'Throws when RegistrantId is missing' {
            { Get-ZoomWebinarRegistrant -WebinarId 123456789 } | Should -Throw
        }
    }
}
