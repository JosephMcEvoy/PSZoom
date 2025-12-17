BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'

    $script:MockResponse = [PSCustomObject]@{
        collaborators = @(
            @{
                id = 'user123'
                email = 'user1@example.com'
                display_name = 'User One'
                permission = 'edit'
            }
            @{
                id = 'user456'
                email = 'user2@example.com'
                display_name = 'User Two'
                permission = 'view'
            }
        )
    }
}

Describe 'Get-ZoomClipCollaborators' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns collaborators data' {
            $result = Get-ZoomClipCollaborators -ClipId 'clip123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns expected properties' {
            $result = Get-ZoomClipCollaborators -ClipId 'clip123'
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'collaborators'
        }

        It 'Calls Invoke-ZoomRestMethod' {
            Get-ZoomClipCollaborators -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Requires ClipId parameter' {
            { Get-ZoomClipCollaborators } | Should -Throw
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URL with ClipId' {
            Get-ZoomClipCollaborators -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/clips/clip123/collaborators'
            }
        }

        It 'Uses GET method' {
            Get-ZoomClipCollaborators -ClipId 'clip123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Handles ClipId with special characters' {
            Get-ZoomClipCollaborators -ClipId 'clip-abc-123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip-abc-123/collaborators'
            }
        }
    }

    Context 'Parameter Aliases' {
        It 'Accepts clip_id alias for ClipId' {
            { Get-ZoomClipCollaborators -clip_id 'clip123' } | Should -Not -Throw
        }

        It 'Accepts id alias for ClipId' {
            { Get-ZoomClipCollaborators -id 'clip123' } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts ClipId from pipeline' {
            $clipId = 'clip123'
            { $clipId | Get-ZoomClipCollaborators } | Should -Not -Throw
        }

        It 'Accepts ClipId from pipeline by property name' {
            $clip = [PSCustomObject]@{ ClipId = 'clip123' }
            { $clip | Get-ZoomClipCollaborators } | Should -Not -Throw
        }

        It 'Processes multiple ClipIds from pipeline' {
            $clipIds = @('clip123', 'clip456', 'clip789')
            $clipIds | Get-ZoomClipCollaborators
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Accepts clip_id alias from pipeline by property name' {
            $clip = [PSCustomObject]@{ clip_id = 'clip123' }
            { $clip | Get-ZoomClipCollaborators } | Should -Not -Throw
        }

        It 'Accepts id alias from pipeline by property name' {
            $clip = [PSCustomObject]@{ id = 'clip123' }
            { $clip | Get-ZoomClipCollaborators } | Should -Not -Throw
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
            Get-ZoomClipCollaborators -ClipId $clipIds
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Calls API once per ClipId in array' {
            $clipIds = @('clip1', 'clip2', 'clip3')
            Get-ZoomClipCollaborators -ClipId $clipIds
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Constructs correct URL for each ClipId in array' {
            Get-ZoomClipCollaborators -ClipId @('clip123', 'clip456')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip123/collaborators'
            }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip456/collaborators'
            }
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Not Found'
            }
            { Get-ZoomClipCollaborators -ClipId 'nonexistent' } | Should -Throw
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
            { Get-ZoomClipCollaborators -ClipId @('clip1', 'clip2', 'clip3') -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
