BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomContactGroupMember' {
    Context 'When adding members to a contact group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    member_ids = @('user123', 'user456')
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            $members = @(@{ type = 1; id = 'user123' })
            Add-ZoomContactGroupMember -GroupId 'grp123' -GroupMembers $members
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/contacts/groups/grp123/members'
            }
        }

        It 'Should use POST method' {
            $members = @(@{ type = 1; id = 'user123' })
            Add-ZoomContactGroupMember -GroupId 'grp123' -GroupMembers $members
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should include group_members in body' {
            $members = @(@{ type = 1; id = 'user123' })
            Add-ZoomContactGroupMember -GroupId 'grp123' -GroupMembers $members
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.group_members -ne $null
            }
        }

        It 'Should return added member IDs' {
            $members = @(@{ type = 1; id = 'user123' })
            $result = Add-ZoomContactGroupMember -GroupId 'grp123' -GroupMembers $members
            $result.member_ids | Should -HaveCount 2
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ member_ids = @() } }
        }

        It 'Should accept pipeline input by property name' {
            $members = @(@{ type = 1; id = 'user123' })
            [PSCustomObject]@{ GroupId = 'grp123'; GroupMembers = $members } | Add-ZoomContactGroupMember
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
