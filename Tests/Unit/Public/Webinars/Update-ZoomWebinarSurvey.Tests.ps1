BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'

    $fixtureFile = "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-survey-patch.json"
    if (Test-Path $fixtureFile) {
        $script:MockResponse = Get-Content $fixtureFile -Raw | ConvertFrom-Json
    } else {
        $script:MockResponse = @{
            custom_survey = @{}
            show_in_the_browser = $true
            third_party_survey = @{}
        }
    }
}

Describe 'Update-ZoomWebinarSurvey' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Should call the API and return a result when ShowInTheBrowser provided' {
            $result = Update-ZoomWebinarSurvey -WebinarId 123456789 -ShowInTheBrowser $true
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return the mock response data' {
            $result = Update-ZoomWebinarSurvey -WebinarId 123456789 -ShowInTheBrowser $true
            $result | Should -Be $script:MockResponse
        }

        It 'Should write warning when no survey parameters provided' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 3>&1 | Should -Match 'No survey parameters provided'
        }
    }

    Context 'API Endpoint Construction' {
        It 'Should construct the correct URL for webinar survey update' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -ShowInTheBrowser $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -ShowInTheBrowser $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should handle numeric webinar IDs' {
            Update-ZoomWebinarSurvey -WebinarId 987654321 -ShowInTheBrowser $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/987654321/survey'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Should accept ShowInTheBrowser parameter' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -ShowInTheBrowser $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"show_in_the_browser"\s*:\s*true'
            }
        }

        It 'Should accept ThirdPartySurvey parameter' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -ThirdPartySurvey 'https://example.com/survey'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"third_party_survey"\s*:\s*"https://example.com/survey"'
            }
        }

        It 'Should accept CustomSurveyLink parameter' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -CustomSurveyLink 'https://example.com/custom'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match 'custom_survey' -and $Body -match '"link"\s*:\s*"https://example.com/custom"'
            }
        }

        It 'Should accept CustomSurveyTitle parameter' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -CustomSurveyTitle 'Survey Title'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match 'custom_survey' -and $Body -match '"title"\s*:\s*"Survey Title"'
            }
        }

        It 'Should accept AnonymousSurvey parameter' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -AnonymousSurvey $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"anonymous"\s*:\s*true'
            }
        }

        It 'Should accept CustomSurveyQuestions parameter' {
            $questions = @(
                @{
                    name = 'Question 1'
                    type = 'single'
                }
            )
            Update-ZoomWebinarSurvey -WebinarId 123456789 -CustomSurveyQuestions $questions

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match 'custom_survey' -and $Body -match 'questions'
            }
        }
    }

    Context 'Parameter Aliases' {
        It 'Should accept webinar_id alias' {
            Update-ZoomWebinarSurvey -webinar_id 123456789 -ShowInTheBrowser $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should accept show_in_the_browser alias' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -show_in_the_browser $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept third_party_survey alias' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -third_party_survey 'https://example.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept custom_survey_link alias' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -custom_survey_link 'https://example.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept anonymous_survey alias' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -anonymous_survey $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        It 'Should accept WebinarId from pipeline by property name' {
            $input = [PSCustomObject]@{ WebinarId = 123456789; ShowInTheBrowser = $true }
            $result = $input | Update-ZoomWebinarSurvey

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should accept webinar_id from pipeline by property name' {
            $input = [PSCustomObject]@{ webinar_id = 987654321; ShowInTheBrowser = $true }
            $result = $input | Update-ZoomWebinarSurvey

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/987654321/survey'
            }
        }

        It 'Should process multiple pipeline objects' {
            $inputs = @(
                [PSCustomObject]@{ WebinarId = 111111111; ShowInTheBrowser = $true },
                [PSCustomObject]@{ WebinarId = 222222222; ShowInTheBrowser = $false }
            )
            $inputs | Update-ZoomWebinarSurvey

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Request Body Construction' {
        It 'Should not include unspecified optional parameters in body' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -ShowInTheBrowser $true

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $bodyObj = $Body | ConvertFrom-Json
                $null -ne $bodyObj.show_in_the_browser -and
                $null -eq $bodyObj.third_party_survey
            }
        }

        It 'Should nest custom survey properties under custom_survey' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -CustomSurveyTitle 'Test'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $bodyObj = $Body | ConvertFrom-Json
                $null -ne $bodyObj.custom_survey -and
                $bodyObj.custom_survey.title -eq 'Test'
            }
        }

        It 'Should combine multiple custom survey properties' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 `
                -CustomSurveyLink 'https://example.com' `
                -CustomSurveyTitle 'Survey'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.custom_survey.link -eq 'https://example.com' -and
                $bodyObj.custom_survey.title -eq 'Survey'
            }
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Webinar not found'
            }
        }

        It 'Should propagate API errors' {
            { Update-ZoomWebinarSurvey -WebinarId 999999999 -ShowInTheBrowser $true } | Should -Throw '*API Error*'
        }
    }

    Context 'ShouldProcess Support' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockResponse
            }
        }

        It 'Should support WhatIf parameter' {
            Update-ZoomWebinarSurvey -WebinarId 123456789 -ShowInTheBrowser $true -WhatIf

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }
}
