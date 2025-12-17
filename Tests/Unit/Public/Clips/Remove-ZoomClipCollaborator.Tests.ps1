BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
}

Describe 'Remove-ZoomClipCollaborator' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $null
        }
    }

    Context 'Basic Functionality' {
        It 'Returns true on successful removal' {
            $result = Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com') -Confirm:$false
            $result | Should -Be $true
        }

        It 'Calls Invoke-ZoomRestMethod' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Requires ClipId parameter' {
            { Remove-ZoomClipCollaborator -CollaboratorIds @('user1@example.com') -Confirm:$false } | Should -Throw
        }

        It 'Requires CollaboratorIds parameter' {
            { Remove-ZoomClipCollaborator -ClipId 'clip123' -Confirm:$false } | Should -Throw
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URL with ClipId' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/clips/clip123/collaborators'
            }
        }

        It 'Uses DELETE method' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Includes request body with collaborator_ids' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com', 'user2@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match 'collaborator_ids'
            }
        }

        It 'Sends correct JSON body structure' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.collaborator_ids -is [array]
            }
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports ShouldProcess' {
            $command = Get-Command Remove-ZoomClipCollaborator
            $command.Parameters['WhatIf'] | Should -Not -BeNullOrEmpty
            $command.Parameters['Confirm'] | Should -Not -BeNullOrEmpty
        }

        It 'Respects WhatIf parameter' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com') -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Does not call API when WhatIf is specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com') -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Has ConfirmImpact set to High' {
            $command = Get-Command Remove-ZoomClipCollaborator
            $command.ScriptBlock.Attributes.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Parameter Aliases' {
        It 'Accepts clip_id alias for ClipId' {
            { Remove-ZoomClipCollaborator -clip_id 'clip123' -CollaboratorIds @('user1@example.com') -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts id alias for ClipId' {
            { Remove-ZoomClipCollaborator -id 'clip123' -CollaboratorIds @('user1@example.com') -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts collaborator_ids alias for CollaboratorIds' {
            { Remove-ZoomClipCollaborator -ClipId 'clip123' -collaborator_ids @('user1@example.com') -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts ClipId from pipeline by property name' {
            $params = [PSCustomObject]@{
                ClipId = 'clip123'
                CollaboratorIds = @('user1@example.com')
            }
            { $params | Remove-ZoomClipCollaborator -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts clip_id alias from pipeline by property name' {
            $params = [PSCustomObject]@{
                clip_id = 'clip123'
                CollaboratorIds = @('user1@example.com')
            }
            { $params | Remove-ZoomClipCollaborator -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts CollaboratorIds from pipeline by property name' {
            $params = [PSCustomObject]@{
                ClipId = 'clip123'
                collaborator_ids = @('user1@example.com')
            }
            { $params | Remove-ZoomClipCollaborator -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'CollaboratorIds Array Handling' {
        It 'Accepts single collaborator ID' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds 'user1@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Accepts multiple collaborator IDs' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com', 'user2@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Includes all collaborator IDs in request body' {
            Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('user1@example.com', 'user2@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.collaborator_ids.Count -eq 2
            }
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Not Found'
            }
            { Remove-ZoomClipCollaborator -ClipId 'nonexistent' -CollaboratorIds @('user1@example.com') -Confirm:$false } | Should -Throw
        }

        It 'Throws error when collaborators not found' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Collaborator not found'
            }
            { Remove-ZoomClipCollaborator -ClipId 'clip123' -CollaboratorIds @('nonexistent@example.com') -Confirm:$false } | Should -Throw
        }
    }
}
