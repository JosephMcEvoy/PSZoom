BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomWebinarRegistrant' {
    Context 'When adding a registrant' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'reg123'
                    registrant_id = 'reg123'
                    start_time = '2025-01-15T10:00:00Z'
                    join_url = 'https://zoom.us/w/123456?tk=xxx'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Add-ZoomWebinarRegistrant -WebinarId 1234567890 -Email 'john@company.com' -FirstName 'John' -LastName 'Doe'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/registrants*'
            }
        }

        It 'Should use POST method' {
            Add-ZoomWebinarRegistrant -WebinarId 1234567890 -Email 'john@company.com' -FirstName 'John' -LastName 'Doe'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should require WebinarId parameter' {
            { Add-ZoomWebinarRegistrant -Email 'john@company.com' -FirstName 'John' -LastName 'Doe' } | Should -Throw
        }

        It 'Should require Email parameter' {
            { Add-ZoomWebinarRegistrant -WebinarId 1234567890 -FirstName 'John' -LastName 'Doe' } | Should -Throw
        }

        It 'Should require FirstName parameter' {
            { Add-ZoomWebinarRegistrant -WebinarId 1234567890 -Email 'john@company.com' -LastName 'Doe' } | Should -Throw
        }

        It 'Should require LastName parameter' {
            { Add-ZoomWebinarRegistrant -WebinarId 1234567890 -Email 'john@company.com' -FirstName 'John' } | Should -Throw
        }

        It 'Should accept optional parameters' {
            { Add-ZoomWebinarRegistrant -WebinarId 1234567890 -Email 'john@company.com' -FirstName 'John' -LastName 'Doe' -City 'New York' -Country 'US' } | Should -Not -Throw
        }

        It 'Should return the response object' {
            $result = Add-ZoomWebinarRegistrant -WebinarId 1234567890 -Email 'john@company.com' -FirstName 'John' -LastName 'Doe'

            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'reg123'
        }
    }
}
