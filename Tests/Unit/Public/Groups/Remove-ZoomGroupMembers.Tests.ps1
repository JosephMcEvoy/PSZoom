BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomGroupMembers' {
    Context 'When removing group members' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should remove member from group' {
            { Remove-ZoomGroupMembers -GroupIds 'group123' -MemberIds 'member456' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should remove multiple members from multiple groups' {
            Remove-ZoomGroupMembers -GroupIds 'group1', 'group2' -MemberIds 'member1', 'member2' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 4
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct members endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/groups/.*/members/.*'
                return @{}
            }

            Remove-ZoomGroupMembers -GroupIds 'group123' -MemberIds 'member456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use DELETE method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'DELETE'
                return @{}
            }

            Remove-ZoomGroupMembers -GroupIds 'group123' -MemberIds 'member456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'SupportsShouldProcess' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            Remove-ZoomGroupMembers -GroupIds 'group123' -MemberIds 'member456' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Parameter validation' {
        It 'Should require GroupIds parameter' {
            { Remove-ZoomGroupMembers -MemberIds 'member456' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Group not found')
            }

            { Remove-ZoomGroupMembers -GroupIds 'nonexistent' -MemberIds 'member' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
