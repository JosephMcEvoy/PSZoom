BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $script:MockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/u-s-e-r-w-e-b-i-n-a-r-t-e-m-p-l-a-t-e-get.json" -Raw | ConvertFrom-Json
}

Describe 'Get-ZoomUserWebinarTemplate' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns webinar templates data' {
            $result = Get-ZoomUserWebinarTemplate -UserId 'jsmith@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Get-ZoomUserWebinarTemplate -UserId 'jsmith@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URL with email UserId' {
            Get-ZoomUserWebinarTemplate -UserId 'jsmith@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'https://api\.zoom\.us/v2/users/jsmith@example\.com/webinar_templates'
            }
        }

        It 'Constructs correct URL with "me" UserId' {
            Get-ZoomUserWebinarTemplate -UserId 'me'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'https://api\.zoom\.us/v2/users/me/webinar_templates'
            }
        }

        It 'Uses GET method' {
            Get-ZoomUserWebinarTemplate -UserId 'jsmith@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires UserId parameter' {
            (Get-Command Get-ZoomUserWebinarTemplate).Parameters['UserId'].Attributes.Mandatory | Should -Contain $True
        }

        It 'Accepts user_id alias' {
            Get-ZoomUserWebinarTemplate -user_id 'jsmith@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts id alias' {
            Get-ZoomUserWebinarTemplate -id 'jsmith@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts Email alias' {
            Get-ZoomUserWebinarTemplate -Email 'jsmith@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts positional parameter' {
            Get-ZoomUserWebinarTemplate 'jsmith@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts pipeline input by value' {
            'jsmith@example.com' | Get-ZoomUserWebinarTemplate
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts pipeline input by property name' {
            [PSCustomObject]@{ UserId = 'jsmith@example.com' } | Get-ZoomUserWebinarTemplate
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Processes multiple pipeline inputs' {
            @('user1@example.com', 'user2@example.com') | Get-ZoomUserWebinarTemplate
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2 -Exactly
        }
    }

    Context 'Error Handling' {
        It 'Throws when API returns error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: User not found'
            }
            { Get-ZoomUserWebinarTemplate -UserId 'nonexistent@example.com' } | Should -Throw
        }

        It 'Throws when UserId is empty string' {
            { Get-ZoomUserWebinarTemplate -UserId '' } | Should -Throw
        }
    }
}
