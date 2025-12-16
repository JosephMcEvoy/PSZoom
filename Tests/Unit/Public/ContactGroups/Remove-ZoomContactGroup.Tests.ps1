BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomContactGroup' {
    Context 'When deleting a contact group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomContactGroup -GroupId 'grp123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/contacts/groups/grp123'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomContactGroup -GroupId 'grp123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should return true on success' {
            $result = Remove-ZoomContactGroup -GroupId 'grp123' -Confirm:$false
            $result | Should -Be $true
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should not call API when -WhatIf is specified' {
            Remove-ZoomContactGroup -GroupId 'grp123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should call API when -Confirm:$false is specified' {
            Remove-ZoomContactGroup -GroupId 'grp123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should accept GroupId from pipeline' {
            'grp123' | Remove-ZoomContactGroup -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept group_id alias from pipeline' {
            [PSCustomObject]@{ group_id = 'grp123' } | Remove-ZoomContactGroup -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
