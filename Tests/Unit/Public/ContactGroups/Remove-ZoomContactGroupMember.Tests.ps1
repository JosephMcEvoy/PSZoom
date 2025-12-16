BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomContactGroupMember' {
    Context 'When removing members from a contact group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomContactGroupMember -GroupId 'grp123' -MemberIds 'user456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/contacts/groups/grp123/members*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomContactGroupMember -GroupId 'grp123' -MemberIds 'user456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should include member_ids in query string' {
            Remove-ZoomContactGroupMember -GroupId 'grp123' -MemberIds 'user456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*member_ids=user456*'
            }
        }

        It 'Should join multiple member IDs with commas' {
            Remove-ZoomContactGroupMember -GroupId 'grp123' -MemberIds @('user1', 'user2', 'user3') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*member_ids=user1%2cuser2%2cuser3*'
            }
        }

        It 'Should return true on success' {
            $result = Remove-ZoomContactGroupMember -GroupId 'grp123' -MemberIds 'user456' -Confirm:$false
            $result | Should -Be $true
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should not call API when -WhatIf is specified' {
            Remove-ZoomContactGroupMember -GroupId 'grp123' -MemberIds 'user456' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should call API when -Confirm:$false is specified' {
            Remove-ZoomContactGroupMember -GroupId 'grp123' -MemberIds 'user456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ GroupId = 'grp123'; MemberIds = @('user456') } | Remove-ZoomContactGroupMember -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
