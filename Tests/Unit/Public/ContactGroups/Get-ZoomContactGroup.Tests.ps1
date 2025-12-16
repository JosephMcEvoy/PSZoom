BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomContactGroup' {
    Context 'When getting a contact group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    group_id      = 'grp123'
                    group_name    = 'Engineering'
                    total_members = 15
                    group_privacy = 2
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomContactGroup -GroupId 'grp123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/contacts/groups/grp123'
            }
        }

        It 'Should use GET method' {
            Get-ZoomContactGroup -GroupId 'grp123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return group details' {
            $result = Get-ZoomContactGroup -GroupId 'grp123'
            $result.group_name | Should -Be 'Engineering'
            $result.total_members | Should -Be 15
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ group_id = 'grp123' } }
        }

        It 'Should accept GroupId from pipeline' {
            'grp123' | Get-ZoomContactGroup
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept group_id alias from pipeline' {
            [PSCustomObject]@{ group_id = 'grp123' } | Get-ZoomContactGroup
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
