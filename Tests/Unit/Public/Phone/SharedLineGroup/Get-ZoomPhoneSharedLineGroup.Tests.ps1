BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneSharedLineGroup' {
    Context 'When retrieving a specific shared line group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'slg123'
                    name = 'Sales Team'
                    extension_number = 5001
                    members = @()
                }
            }
        }

        It 'Should return a shared line group' {
            $result = Get-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123'
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'slg123'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/shared_line_groups/slg123'
                return @{ id = 'slg123' }
            }

            Get-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ id = 'slg123' }
            }

            Get-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123'
        }
    }

    Context 'When retrieving multiple shared line groups' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                if ($Uri -match 'slg123') {
                    return @{ id = 'slg123'; name = 'Sales Team' }
                } elseif ($Uri -match 'slg456') {
                    return @{ id = 'slg456'; name = 'Support Team' }
                }
            }
        }

        It 'Should handle multiple SharedLineGroupIds' {
            $result = Get-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123', 'slg456'
            $result.Count | Should -Be 2
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'slg123' }
            }
        }

        It 'Should accept SharedLineGroupId from pipeline' {
            { 'slg123' | Get-ZoomPhoneSharedLineGroup } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $slgObject = [PSCustomObject]@{ id = 'slg123' }
            { $slgObject | Get-ZoomPhoneSharedLineGroup } | Should -Not -Throw
        }

        It 'Should accept object with slgId property from pipeline' {
            $slgObject = [PSCustomObject]@{ slgId = 'slg123' }
            { $slgObject | Get-ZoomPhoneSharedLineGroup } | Should -Not -Throw
        }

        It 'Should accept object with shared_line_group_id property from pipeline' {
            $slgObject = [PSCustomObject]@{ shared_line_group_id = 'slg123' }
            { $slgObject | Get-ZoomPhoneSharedLineGroup } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'slg123' }
            }
        }

        It 'Should accept slgId alias' {
            { Get-ZoomPhoneSharedLineGroup -slgId 'slg123' } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Get-ZoomPhoneSharedLineGroup -id 'slg123' } | Should -Not -Throw
        }

        It 'Should accept shared_line_group_id alias' {
            { Get-ZoomPhoneSharedLineGroup -shared_line_group_id 'slg123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require SharedLineGroupId parameter' {
            { Get-ZoomPhoneSharedLineGroup -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Shared line group not found')
            }

            { Get-ZoomPhoneSharedLineGroup -SharedLineGroupId 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }
}
