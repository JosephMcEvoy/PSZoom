BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'

    $script:MockResponse = [PSCustomObject]@{
        comments = @(
            @{
                id = 'comment123'
                user_id = 'user123'
                user_email = 'user1@example.com'
                user_name = 'User One'
                comment = 'Great presentation!'
                timestamp = '2023-01-15T10:00:00Z'
            }
            @{
                id = 'comment456'
                user_id = 'user456'
                user_email = 'user2@example.com'
                user_name = 'User Two'
                comment = 'Very informative'
                timestamp = '2023-01-15T10:05:00Z'
            }
        )
    }
}

Describe 'Get-ZoomClipComments' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns comments data' {
            $result = Get-ZoomClipComments -ClipId 'clip123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns expected properties' {
            $result = Get-ZoomClipComments -ClipId 'clip123'
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'comments'
        }

        It 'Calls Invoke-ZoomRestMethod' {
            Get-ZoomClipComments -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Requires ClipId parameter' {
            { Get-ZoomClipComments } | Should -Throw
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URL with ClipId' {
            Get-ZoomClipComments -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/clips/clip123/comments'
            }
        }

        It 'Uses GET method' {
            Get-ZoomClipComments -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Handles ClipId with special characters' {
            Get-ZoomClipComments -ClipId 'clip-abc-123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip-abc-123/comments'
            }
        }
    }

    Context 'Parameter Aliases' {
        It 'Accepts clip_id alias for ClipId' {
            { Get-ZoomClipComments -clip_id 'clip123' } | Should -Not -Throw
        }

        It 'Accepts id alias for ClipId' {
            { Get-ZoomClipComments -id 'clip123' } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts ClipId from pipeline' {
            $clipId = 'clip123'
            { $clipId | Get-ZoomClipComments } | Should -Not -Throw
        }

        It 'Accepts ClipId from pipeline by property name' {
            $clip = [PSCustomObject]@{ ClipId = 'clip123' }
            { $clip | Get-ZoomClipComments } | Should -Not -Throw
        }

        It 'Processes multiple ClipIds from pipeline' {
            $clipIds = @('clip123', 'clip456', 'clip789')
            $clipIds | Get-ZoomClipComments
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Accepts clip_id alias from pipeline by property name' {
            $clip = [PSCustomObject]@{ clip_id = 'clip123' }
            { $clip | Get-ZoomClipComments } | Should -Not -Throw
        }

        It 'Accepts id alias from pipeline by property name' {
            $clip = [PSCustomObject]@{ id = 'clip123' }
            { $clip | Get-ZoomClipComments } | Should -Not -Throw
        }
    }

    Context 'Array Processing' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                return $script:MockResponse
            }
        }

        It 'Processes array of ClipIds' {
            $clipIds = @('clip123', 'clip456')
            Get-ZoomClipComments -ClipId $clipIds
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Calls API once per ClipId in array' {
            $clipIds = @('clip1', 'clip2', 'clip3')
            Get-ZoomClipComments -ClipId $clipIds
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Constructs correct URL for each ClipId in array' {
            Get-ZoomClipComments -ClipId @('clip123', 'clip456')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip123/comments'
            }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip456/comments'
            }
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Not Found'
            }
            { Get-ZoomClipComments -ClipId 'nonexistent' } | Should -Throw
        }

        It 'Continues processing remaining clips on error' {
            $callCount = 0
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                $callCount++
                if ($callCount -eq 2) {
                    throw 'API Error'
                }
                return $script:MockResponse
            }
            { Get-ZoomClipComments -ClipId @('clip1', 'clip2', 'clip3') -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
