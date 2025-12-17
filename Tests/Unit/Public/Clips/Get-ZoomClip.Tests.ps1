BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'

    $script:MockResponse = @{
        id = 'clip123'
        name = 'Test Clip'
        description = 'Test Description'
        duration = 120
        file_size = 1048576
        created_at = '2023-01-15T10:00:00Z'
        owner_id = 'user123'
        owner_email = 'owner@example.com'
        status = 'available'
    }
}

Describe 'Get-ZoomClip' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns clip data' {
            $result = Get-ZoomClip -ClipId 'clip123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns expected properties' {
            $result = Get-ZoomClip -ClipId 'clip123'
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'id'
        }

        It 'Calls Invoke-ZoomRestMethod' {
            Get-ZoomClip -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Requires ClipId parameter' {
            { Get-ZoomClip } | Should -Throw
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URL with ClipId' {
            Get-ZoomClip -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/clips/clip123'
            }
        }

        It 'Uses GET method' {
            Get-ZoomClip -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Handles ClipId with special characters' {
            Get-ZoomClip -ClipId 'clip-abc-123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip-abc-123'
            }
        }
    }

    Context 'Parameter Aliases' {
        It 'Accepts clip_id alias for ClipId' {
            { Get-ZoomClip -clip_id 'clip123' } | Should -Not -Throw
        }

        It 'Accepts id alias for ClipId' {
            { Get-ZoomClip -id 'clip123' } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts ClipId from pipeline' {
            $clipId = 'clip123'
            { $clipId | Get-ZoomClip } | Should -Not -Throw
        }

        It 'Accepts ClipId from pipeline by property name' {
            $clip = [PSCustomObject]@{ ClipId = 'clip123' }
            { $clip | Get-ZoomClip } | Should -Not -Throw
        }

        It 'Processes multiple ClipIds from pipeline' {
            $clipIds = @('clip123', 'clip456', 'clip789')
            $clipIds | Get-ZoomClip
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Accepts clip_id alias from pipeline by property name' {
            $clip = [PSCustomObject]@{ clip_id = 'clip123' }
            { $clip | Get-ZoomClip } | Should -Not -Throw
        }

        It 'Accepts id alias from pipeline by property name' {
            $clip = [PSCustomObject]@{ id = 'clip123' }
            { $clip | Get-ZoomClip } | Should -Not -Throw
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
            Get-ZoomClip -ClipId $clipIds
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Calls API once per ClipId in array' {
            $clipIds = @('clip1', 'clip2', 'clip3')
            Get-ZoomClip -ClipId $clipIds
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Constructs correct URL for each ClipId in array' {
            Get-ZoomClip -ClipId @('clip123', 'clip456')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip123'
            }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip456'
            }
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Not Found'
            }
            { Get-ZoomClip -ClipId 'nonexistent' } | Should -Throw
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
            { Get-ZoomClip -ClipId @('clip1', 'clip2', 'clip3') -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
