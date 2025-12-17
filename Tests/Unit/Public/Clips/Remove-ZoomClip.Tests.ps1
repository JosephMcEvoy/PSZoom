BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
}

Describe 'Remove-ZoomClip' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $null
        }
    }

    Context 'Basic Functionality' {
        It 'Returns true on successful deletion' {
            $result = Remove-ZoomClip -ClipId 'clip123' -Confirm:$false
            $result | Should -Be $true
        }

        It 'Calls Invoke-ZoomRestMethod' {
            Remove-ZoomClip -ClipId 'clip123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Requires ClipId parameter' {
            { Remove-ZoomClip -Confirm:$false } | Should -Throw
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URL with ClipId' {
            Remove-ZoomClip -ClipId 'clip123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/clips/clip123'
            }
        }

        It 'Uses DELETE method' {
            Remove-ZoomClip -ClipId 'clip123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Handles ClipId with special characters' {
            Remove-ZoomClip -ClipId 'clip-abc-123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip-abc-123'
            }
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports ShouldProcess' {
            $command = Get-Command Remove-ZoomClip
            $command.Parameters['WhatIf'] | Should -Not -BeNullOrEmpty
            $command.Parameters['Confirm'] | Should -Not -BeNullOrEmpty
        }

        It 'Respects WhatIf parameter' {
            Remove-ZoomClip -ClipId 'clip123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Does not call API when WhatIf is specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom
            Remove-ZoomClip -ClipId 'clip123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Has ConfirmImpact set to High' {
            $command = Get-Command Remove-ZoomClip
            $command.ScriptBlock.Attributes.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Parameter Aliases' {
        It 'Accepts clip_id alias for ClipId' {
            { Remove-ZoomClip -clip_id 'clip123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts id alias for ClipId' {
            { Remove-ZoomClip -id 'clip123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts ClipId from pipeline' {
            $clipId = 'clip123'
            { $clipId | Remove-ZoomClip -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts ClipId from pipeline by property name' {
            $clip = [PSCustomObject]@{ ClipId = 'clip123' }
            { $clip | Remove-ZoomClip -Confirm:$false } | Should -Not -Throw
        }

        It 'Processes multiple ClipIds from pipeline' {
            $clipIds = @('clip123', 'clip456', 'clip789')
            $clipIds | Remove-ZoomClip -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Accepts clip_id alias from pipeline by property name' {
            $clip = [PSCustomObject]@{ clip_id = 'clip123' }
            { $clip | Remove-ZoomClip -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts id alias from pipeline by property name' {
            $clip = [PSCustomObject]@{ id = 'clip123' }
            { $clip | Remove-ZoomClip -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Array Processing' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                return $null
            }
        }

        It 'Processes array of ClipIds' {
            $clipIds = @('clip123', 'clip456')
            Remove-ZoomClip -ClipId $clipIds -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Calls API once per ClipId in array' {
            $clipIds = @('clip1', 'clip2', 'clip3')
            Remove-ZoomClip -ClipId $clipIds -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Returns true for each successfully deleted clip' {
            $clipIds = @('clip1', 'clip2')
            $results = Remove-ZoomClip -ClipId $clipIds -Confirm:$false
            $results | Should -HaveCount 2
            $results | Should -AllBe $true
        }

        It 'Constructs correct URL for each ClipId in array' {
            Remove-ZoomClip -ClipId @('clip123', 'clip456') -Confirm:$false
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
            { Remove-ZoomClip -ClipId 'nonexistent' -Confirm:$false } | Should -Throw
        }

        It 'Continues processing remaining clips on error' {
            $callCount = 0
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                $callCount++
                if ($callCount -eq 2) {
                    throw 'API Error'
                }
                return $null
            }
            { Remove-ZoomClip -ClipId @('clip1', 'clip2', 'clip3') -Confirm:$false -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
