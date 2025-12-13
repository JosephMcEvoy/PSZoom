BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    $script:MockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-registrant-question-patch.json" -Raw | ConvertFrom-Json
}

Describe 'Update-ZoomWebinarRegistrantQuestion' {
    BeforeEach {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns data when called with WebinarId and Questions' {
            $questions = @(
                @{ field_name = 'address'; required = $true }
                @{ field_name = 'city'; required = $false }
            )
            $result = Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -Questions $questions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns data when called with WebinarId and CustomQuestions' {
            $customQuestions = @(
                @{ title = 'Company Name'; type = 'short'; required = $true }
            )
            $result = Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -CustomQuestions $customQuestions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns data when called with both Questions and CustomQuestions' {
            $questions = @(
                @{ field_name = 'address'; required = $true }
            )
            $customQuestions = @(
                @{ title = 'Job Title'; type = 'short'; required = $false }
            )
            $result = Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -Questions $questions -CustomQuestions $customQuestions
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs the correct API endpoint URL' {
            $questions = @(
                @{ field_name = 'address'; required = $true }
            )
            Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -Questions $questions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'webinars/123456789/registrants/questions'
            }
        }

        It 'Uses PATCH method for the API call' {
            $questions = @(
                @{ field_name = 'city'; required = $false }
            )
            Update-ZoomWebinarRegistrantQuestion -WebinarId '987654321' -Questions $questions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'PATCH'
            }
        }

        It 'Includes questions in the request body' {
            $questions = @(
                @{ field_name = 'country'; required = $true }
            )
            Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -Questions $questions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match 'questions'
            }
        }

        It 'Includes custom_questions in the request body' {
            $customQuestions = @(
                @{ title = 'Department'; type = 'short'; required = $true }
            )
            Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -CustomQuestions $customQuestions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match 'custom_questions'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Accepts webinar_id as parameter alias' {
            $questions = @(
                @{ field_name = 'address'; required = $true }
            )
            $result = Update-ZoomWebinarRegistrantQuestion -webinar_id '123456789' -Questions $questions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts id as parameter alias for WebinarId' {
            $questions = @(
                @{ field_name = 'city'; required = $false }
            )
            $result = Update-ZoomWebinarRegistrantQuestion -id '123456789' -Questions $questions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts question as parameter alias for Questions' {
            $questions = @(
                @{ field_name = 'state'; required = $true }
            )
            $result = Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -question $questions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts custom_questions as parameter alias for CustomQuestions' {
            $customQuestions = @(
                @{ title = 'Role'; type = 'short'; required = $false }
            )
            $result = Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -custom_questions $customQuestions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts customquestion as parameter alias for CustomQuestions' {
            $customQuestions = @(
                @{ title = 'Team'; type = 'short'; required = $true }
            )
            $result = Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -customquestion $customQuestions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Requires WebinarId parameter' {
            { Update-ZoomWebinarRegistrantQuestion -Questions @(@{ field_name = 'address'; required = $true }) } | Should -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by property name' {
            $questions = @(
                @{ field_name = 'zip'; required = $false }
            )
            $pipelineInput = [PSCustomObject]@{ WebinarId = '123456789' }
            $result = $pipelineInput | Update-ZoomWebinarRegistrantQuestion -Questions $questions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Accepts webinar_id from pipeline by property name' {
            $questions = @(
                @{ field_name = 'phone'; required = $true }
            )
            $pipelineInput = [PSCustomObject]@{ webinar_id = '987654321' }
            $result = $pipelineInput | Update-ZoomWebinarRegistrantQuestion -Questions $questions
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Processes multiple webinar IDs from pipeline' {
            $questions = @(
                @{ field_name = 'industry'; required = $false }
            )
            $pipelineInput = @(
                [PSCustomObject]@{ WebinarId = '111111111' }
                [PSCustomObject]@{ WebinarId = '222222222' }
            )
            $pipelineInput | Update-ZoomWebinarRegistrantQuestion -Questions $questions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { throw 'API Error' }
            { Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -Questions @(@{ field_name = 'address'; required = $true }) } | Should -Throw
        }

        It 'Handles invalid webinar ID format' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith { throw 'Invalid webinar ID' }
            { Update-ZoomWebinarRegistrantQuestion -WebinarId 'invalid-id' -Questions @(@{ field_name = 'city'; required = $false }) } | Should -Throw
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            $questions = @(
                @{ field_name = 'address'; required = $true }
            )
            Update-ZoomWebinarRegistrantQuestion -WebinarId '123456789' -Questions $questions -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }
}
