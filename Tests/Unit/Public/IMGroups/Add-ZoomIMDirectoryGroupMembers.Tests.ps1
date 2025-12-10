BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomIMDirectoryGroupMembers' {
    Context 'When adding members by email' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    ids = @('member-123', 'member-456')
                    added_at = '2024-12-09T10:00:00Z'
                }
            }
        }

        It 'Should complete without error' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept multiple emails' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user1@example.com', 'user2@example.com' } | Should -Not -Throw
        }

        It 'Should call the API' {
            Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'When adding members by ID' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    ids = @('member-123')
                    added_at = '2024-12-09T10:00:00Z'
                }
            }
        }

        It 'Should complete without error' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -MemberId 'member-123' } | Should -Not -Throw
        }

        It 'Should accept multiple member IDs' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -MemberId 'member-123', 'member-456' } | Should -Not -Throw
        }

        It 'Should call the API' {
            Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -MemberId 'member-123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'When adding members by both email and ID' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept both Email and MemberId parameters' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com' -MemberId 'member-123' } | Should -Not -Throw
        }

        It 'Should call the API' {
            Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com' -MemberId 'member-123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'API endpoint construction' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call API with correct IM group members endpoint' {
            Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*/v2/im/groups/group-123/members'
            }
        }

        It 'Should use POST method' {
            Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }
    }

    Context 'When handling multiple groups' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept multiple GroupIds' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123', 'group-456' -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should call API once for each group' {
            Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123', 'group-456' -Email 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Parameter validation' {
        It 'Should require GroupId parameter' {
            { Add-ZoomIMDirectoryGroupMembers -Email 'user@example.com' } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept GroupId from pipeline' {
            { 'group-123' | Add-ZoomIMDirectoryGroupMembers -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept object with group_id property from pipeline' {
            $groupObject = [PSCustomObject]@{ group_id = 'group-123' }
            { $groupObject | Add-ZoomIMDirectoryGroupMembers -Email 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept group_id alias for GroupId' {
            { Add-ZoomIMDirectoryGroupMembers -group_id 'group-123' -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept MemberEmail alias for Email' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -MemberEmail 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept memberids alias for MemberId' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -memberids 'member-123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept GroupId as first positional parameter' {
            { Add-ZoomIMDirectoryGroupMembers 'group-123' -Email 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    ids = @('member-123')
                }
            }
        }

        It 'Should return GroupId when Passthru is specified' {
            $result = Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com' -Passthru
            $result | Should -Be 'group-123'
        }

        It 'Should return API response when Passthru is not specified' {
            $result = Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com'
            $result.ids | Should -Contain 'member-123'
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf parameter' {
            { Add-ZoomIMDirectoryGroupMembers -GroupId 'group-123' -Email 'user@example.com' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Group not found')
            }

            { Add-ZoomIMDirectoryGroupMembers -GroupId 'nonexistent' -Email 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
