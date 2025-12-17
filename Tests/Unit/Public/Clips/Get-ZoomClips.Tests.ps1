BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'

    $script:MockResponse = @{
        clips = @(
            @{
                id = 'clip123'
                name = 'Test Clip 1'
                description = 'Test Description'
                duration = 120
                file_size = 1048576
                created_at = '2023-01-15T10:00:00Z'
            }
            @{
                id = 'clip456'
                name = 'Test Clip 2'
                description = 'Another Test'
                duration = 90
                file_size = 524288
                created_at = '2023-01-16T14:30:00Z'
            }
        )
        page_size = 30
        next_page_token = ''
    }
}

Describe 'Get-ZoomClips' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns clips data' {
            $result = Get-ZoomClips
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns expected properties' {
            $result = Get-ZoomClips
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'clips'
        }

        It 'Calls Invoke-ZoomRestMethod' {
            Get-ZoomClips
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct base URL' {
            Get-ZoomClips
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/clips'
            }
        }

        It 'Uses GET method' {
            Get-ZoomClips
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Includes page_size parameter in query string when specified' {
            Get-ZoomClips -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_size=50'
            }
        }

        It 'Includes next_page_token when specified' {
            Get-ZoomClips -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Accepts valid PageSize within range' {
            { Get-ZoomClips -PageSize 100 } | Should -Not -Throw
        }

        It 'Accepts minimum PageSize of 1' {
            { Get-ZoomClips -PageSize 1 } | Should -Not -Throw
        }

        It 'Accepts maximum PageSize of 300' {
            { Get-ZoomClips -PageSize 300 } | Should -Not -Throw
        }

        It 'Rejects PageSize below minimum' {
            { Get-ZoomClips -PageSize 0 } | Should -Throw
        }

        It 'Rejects PageSize above maximum' {
            { Get-ZoomClips -PageSize 301 } | Should -Throw
        }
    }

    Context 'Parameter Aliases' {
        It 'Accepts page_size alias for PageSize' {
            { Get-ZoomClips -page_size 50 } | Should -Not -Throw
        }

        It 'Accepts next_page_token alias for NextPageToken' {
            { Get-ZoomClips -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts PageSize from pipeline by property name' {
            $params = [PSCustomObject]@{ PageSize = 50 }
            { $params | Get-ZoomClips } | Should -Not -Throw
        }

        It 'Accepts NextPageToken from pipeline by property name' {
            $params = [PSCustomObject]@{ NextPageToken = 'token123' }
            { $params | Get-ZoomClips } | Should -Not -Throw
        }

        It 'Accepts multiple parameters from pipeline' {
            $params = [PSCustomObject]@{
                PageSize = 100
                NextPageToken = 'token123'
            }
            { $params | Get-ZoomClips } | Should -Not -Throw
        }
    }

    Context 'Pagination' {
        It 'Includes next_page_token for pagination' {
            Get-ZoomClips -NextPageToken 'abcdef123456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'next_page_token=abcdef123456'
            }
        }

        It 'Combines pagination with page size' {
            Get-ZoomClips -PageSize 100 -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_size=100' -and
                $Uri -match 'next_page_token=token123'
            }
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Unauthorized'
            }
            { Get-ZoomClips } | Should -Throw
        }
    }
}
