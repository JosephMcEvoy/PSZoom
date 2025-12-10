BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomGroupMember' {
    Context 'When adding members to a group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ ids = @('member123'); added_at = '2024-01-15T10:00:00Z' }
            }
        }

        It 'Should complete without error' {
            { Add-ZoomGroupMember -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -MemberEmail 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct group members endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/groups/.*/members'
                return @{}
            }

            Add-ZoomGroupMember -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -MemberEmail 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{}
            }

            Add-ZoomGroupMember -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -MemberEmail 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Multiple members' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept multiple member emails' {
            { Add-ZoomGroupMember -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -MemberEmail 'user1@example.com', 'user2@example.com' } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept GroupId from pipeline' {
            { 'gVcjZnYYRLDbb5F3VRzxJw' | Add-ZoomGroupMember -MemberEmail 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require GroupId parameter' {
            { Add-ZoomGroupMember -MemberEmail 'user@example.com' } | Should -Throw
        }

        It 'Should require MemberEmail parameter' {
            { Add-ZoomGroupMember -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Group not found')
            }

            { Add-ZoomGroupMember -GroupId 'nonexistent' -MemberEmail 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
