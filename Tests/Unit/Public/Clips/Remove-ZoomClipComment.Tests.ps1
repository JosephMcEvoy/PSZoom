BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
}

Describe 'Remove-ZoomClipComment' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $null
        }
    }

    Context 'Basic Functionality' {
        It 'Returns true on successful deletion' {
            $result = Remove-ZoomClipComment -ClipId 'clip123' -CommentId 'comment123' -Confirm:$false
            $result | Should -Be $true
        }

        It 'Calls Invoke-ZoomRestMethod' {
            Remove-ZoomClipComment -ClipId 'clip123' -CommentId 'comment123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Requires ClipId parameter' {
            { Remove-ZoomClipComment -CommentId 'comment123' -Confirm:$false } | Should -Throw
        }

        It 'Requires CommentId parameter' {
            { Remove-ZoomClipComment -ClipId 'clip123' -Confirm:$false } | Should -Throw
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URL with ClipId and CommentId' {
            Remove-ZoomClipComment -ClipId 'clip123' -CommentId 'comment123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/clips/clip123/comments/comment123'
            }
        }

        It 'Uses DELETE method' {
            Remove-ZoomClipComment -ClipId 'clip123' -CommentId 'comment123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Handles ClipId with special characters' {
            Remove-ZoomClipComment -ClipId 'clip-abc-123' -CommentId 'comment-xyz-789' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'clip-abc-123/comments/comment-xyz-789'
            }
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports ShouldProcess' {
            $command = Get-Command Remove-ZoomClipComment
            $command.Parameters['WhatIf'] | Should -Not -BeNullOrEmpty
            $command.Parameters['Confirm'] | Should -Not -BeNullOrEmpty
        }

        It 'Respects WhatIf parameter' {
            Remove-ZoomClipComment -ClipId 'clip123' -CommentId 'comment123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Does not call API when WhatIf is specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom
            Remove-ZoomClipComment -ClipId 'clip123' -CommentId 'comment123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Has ConfirmImpact set to High' {
            $command = Get-Command Remove-ZoomClipComment
            $command.ScriptBlock.Attributes.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Parameter Aliases' {
        It 'Accepts clip_id alias for ClipId' {
            { Remove-ZoomClipComment -clip_id 'clip123' -CommentId 'comment123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts comment_id alias for CommentId' {
            { Remove-ZoomClipComment -ClipId 'clip123' -comment_id 'comment123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts id alias for CommentId' {
            { Remove-ZoomClipComment -ClipId 'clip123' -id 'comment123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts parameters from pipeline by property name' {
            $params = [PSCustomObject]@{
                ClipId = 'clip123'
                CommentId = 'comment123'
            }
            { $params | Remove-ZoomClipComment -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts clip_id alias from pipeline by property name' {
            $params = [PSCustomObject]@{
                clip_id = 'clip123'
                CommentId = 'comment123'
            }
            { $params | Remove-ZoomClipComment -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts comment_id alias from pipeline by property name' {
            $params = [PSCustomObject]@{
                ClipId = 'clip123'
                comment_id = 'comment123'
            }
            { $params | Remove-ZoomClipComment -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts id alias from pipeline by property name' {
            $params = [PSCustomObject]@{
                ClipId = 'clip123'
                id = 'comment123'
            }
            { $params | Remove-ZoomClipComment -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter Positions' {
        It 'Accepts ClipId as first positional parameter' {
            { Remove-ZoomClipComment 'clip123' -CommentId 'comment123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts CommentId as second positional parameter' {
            { Remove-ZoomClipComment 'clip123' 'comment123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Constructs correct URL with positional parameters' {
            Remove-ZoomClipComment 'clip123' 'comment456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/v2/clips/clip123/comments/comment456'
            }
        }
    }

    Context 'Error Handling' {
        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Not Found'
            }
            { Remove-ZoomClipComment -ClipId 'nonexistent' -CommentId 'comment123' -Confirm:$false } | Should -Throw
        }

        It 'Throws error when comment not found' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Comment not found'
            }
            { Remove-ZoomClipComment -ClipId 'clip123' -CommentId 'nonexistent' -Confirm:$false } | Should -Throw
        }
    }
}
