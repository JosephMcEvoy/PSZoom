BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomPhoneSharedLineGroupMembers' {
    Context 'When adding a single member' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    ids = @('user123')
                }
            }
        }

        It 'Should add a member with MemberId parameter' {
            $result = Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -MemberId 'user123' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/shared_line_groups/slg123/members'
                return @{ ids = @('user123') }
            }

            Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -MemberId 'user123' -Confirm:$false
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{ ids = @('user123') }
            }

            Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -MemberId 'user123' -Confirm:$false
        }

        It 'Should include member in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.members.Count | Should -Be 1
                $bodyObj.members[0].id | Should -Be 'user123'
                return @{ ids = @('user123') }
            }

            Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -MemberId 'user123' -Confirm:$false
        }
    }

    Context 'When adding multiple members' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    ids = @('user123', 'user456')
                }
            }
        }

        It 'Should add members with Members parameter' {
            $members = @(
                @{id = 'user123'},
                @{id = 'user456'}
            )
            $result = Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -Members $members -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include all members in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.members.Count | Should -Be 2
                $bodyObj.members[0].id | Should -Be 'user123'
                $bodyObj.members[1].id | Should -Be 'user456'
                return @{ ids = @('user123', 'user456') }
            }

            $members = @(
                @{id = 'user123'},
                @{id = 'user456'}
            )
            Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -Members $members -Confirm:$false
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ ids = @('user123') }
            }
        }

        It 'Should support WhatIf' {
            { Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -MemberId 'user123' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm' {
            Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -MemberId 'user123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ ids = @('user123') }
            }
        }

        It 'Should accept SharedLineGroupId from pipeline' {
            { 'slg123' | Add-ZoomPhoneSharedLineGroupMembers -MemberId 'user123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $slgObject = [PSCustomObject]@{ id = 'slg123' }
            { $slgObject | Add-ZoomPhoneSharedLineGroupMembers -MemberId 'user123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ ids = @('user123') }
            }
        }

        It 'Should accept slgId alias for SharedLineGroupId' {
            { Add-ZoomPhoneSharedLineGroupMembers -slgId 'slg123' -MemberId 'user123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept member_id alias for MemberId' {
            { Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -member_id 'user123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept extension_id alias for MemberId' {
            { Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -extension_id 'user123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter sets' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ ids = @('user123') }
            }
        }

        It 'Should not allow both MemberId and Members parameters' {
            $members = @(@{id = 'user123'})
            { Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -MemberId 'user123' -Members $members -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should require either MemberId or Members parameter' {
            { Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require SharedLineGroupId parameter' {
            { Add-ZoomPhoneSharedLineGroupMembers -MemberId 'user123' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API Error')
            }

            { Add-ZoomPhoneSharedLineGroupMembers -SharedLineGroupId 'slg123' -MemberId 'user123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
