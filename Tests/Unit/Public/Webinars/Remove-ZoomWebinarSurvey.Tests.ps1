BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    
    $fixtureFile = "$PSScriptRoot/../../../Fixtures/MockResponses/w-e-b-i-n-a-r-s-u-r-v-e-y-delete.json"
    if (Test-Path $fixtureFile) {
        $script:MockResponse = Get-Content -Path $fixtureFile -Raw | ConvertFrom-Json
    } else {
        $script:MockResponse = $null
    }
}

Describe 'Remove-ZoomWebinarSurvey' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Should execute without error' {
            { Remove-ZoomWebinarSurvey -WebinarId 123456789 -Confirm:$false } | Should -Not -Throw
        }

        It 'Should call Invoke-ZoomRestMethod' {
            Remove-ZoomWebinarSurvey -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return expected response' {
            $result = Remove-ZoomWebinarSurvey -WebinarId 123456789 -Confirm:$false
            if ($null -ne $script:MockResponse) {
                $result | Should -Not -BeNullOrEmpty
            } else {
                $result | Should -BeNullOrEmpty
            }
        }
    }

    Context 'API Endpoint Construction' {
        It 'Should call correct endpoint' {
            Remove-ZoomWebinarSurvey -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomWebinarSurvey -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should handle different webinar IDs correctly' {
            Remove-ZoomWebinarSurvey -WebinarId 987654321 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/987654321/survey'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Should require WebinarId parameter' {
            (Get-Command Remove-ZoomWebinarSurvey).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Should accept webinar_id as alias' {
            { Remove-ZoomWebinarSurvey -webinar_id 123456789 -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should accept Id as alias' {
            { Remove-ZoomWebinarSurvey -Id 123456789 -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should have WebinarId parameter as Int64 type' {
            (Get-Command Remove-ZoomWebinarSurvey).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }
    }

    Context 'Pipeline Support' {
        It 'Should accept WebinarId from pipeline by value' {
            { 123456789 | Remove-ZoomWebinarSurvey -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept WebinarId from pipeline by property name' {
            $webinarObj = [PSCustomObject]@{ WebinarId = 123456789 }
            { $webinarObj | Remove-ZoomWebinarSurvey -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should accept webinar_id from pipeline by property name' {
            $webinarObj = [PSCustomObject]@{ webinar_id = 123456789 }
            { $webinarObj | Remove-ZoomWebinarSurvey -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should accept Id from pipeline by property name' {
            $webinarObj = [PSCustomObject]@{ Id = 123456789 }
            { $webinarObj | Remove-ZoomWebinarSurvey -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/survey'
            }
        }

        It 'Should process multiple items from pipeline' {
            $webinarIds = @(111111111, 222222222, 333333333)
            { $webinarIds | Remove-ZoomWebinarSurvey -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }
    }

    Context 'ShouldProcess Support' {
        It 'Should support WhatIf parameter' {
            (Get-Command Remove-ZoomWebinarSurvey).Parameters.ContainsKey('WhatIf') | Should -Be $true
        }

        It 'Should support Confirm parameter' {
            (Get-Command Remove-ZoomWebinarSurvey).Parameters.ContainsKey('Confirm') | Should -Be $true
        }

        It 'Should not call API when WhatIf is specified' {
            Remove-ZoomWebinarSurvey -WebinarId 123456789 -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Survey not found'
            }
        }

        It 'Should throw on API error' {
            { Remove-ZoomWebinarSurvey -WebinarId 123456789 -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
