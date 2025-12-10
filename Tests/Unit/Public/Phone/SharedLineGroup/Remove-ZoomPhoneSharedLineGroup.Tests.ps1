BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomPhoneSharedLineGroup' {
    Context 'When removing a shared line group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should remove a shared line group' {
            Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/shared_line_groups/slg123'
                return @{}
            }

            Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Confirm:$false
        }

        It 'Should use DELETE method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'DELETE'
                return @{}
            }

            Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Confirm:$false
        }
    }

    Context 'When removing multiple shared line groups' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should handle multiple SharedLineGroupIds' {
            Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123', 'slg456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'PassThru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should return SharedLineGroupId when PassThru is specified' {
            $result = Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -PassThru -Confirm:$false
            $result | Should -Be 'slg123'
        }

        It 'Should return multiple SharedLineGroupIds when PassThru is specified' {
            $result = Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123', 'slg456' -PassThru -Confirm:$false
            $result.Count | Should -Be 2
            $result[0] | Should -Be 'slg123'
            $result[1] | Should -Be 'slg456'
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            { Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm' {
            Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have High impact' {
            $command = Get-Command Remove-ZoomPhoneSharedLineGroup
            $command.Parameters['Confirm'].Attributes.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept SharedLineGroupId from pipeline' {
            { 'slg123' | Remove-ZoomPhoneSharedLineGroup -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept multiple SharedLineGroupIds from pipeline' {
            { 'slg123', 'slg456' | Remove-ZoomPhoneSharedLineGroup -Confirm:$false } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with id property from pipeline' {
            $slgObject = [PSCustomObject]@{ id = 'slg123' }
            { $slgObject | Remove-ZoomPhoneSharedLineGroup -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept slgId alias' {
            { Remove-ZoomPhoneSharedLineGroup -slgId 'slg123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Remove-ZoomPhoneSharedLineGroup -id 'slg123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept shared_line_group_id alias' {
            { Remove-ZoomPhoneSharedLineGroup -shared_line_group_id 'slg123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require SharedLineGroupId parameter' {
            { Remove-ZoomPhoneSharedLineGroup -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Shared line group not found')
            }

            { Remove-ZoomPhoneSharedLineGroup -SharedLineGroupId 'invalid' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
