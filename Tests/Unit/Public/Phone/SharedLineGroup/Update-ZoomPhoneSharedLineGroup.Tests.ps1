BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomPhoneSharedLineGroup' {
    Context 'When updating a shared line group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should update with Name parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'New Sales Team'
                return @{}
            }

            Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Sales Team' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/shared_line_groups/slg123'
                return @{}
            }

            Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Name' -Confirm:$false
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Name' -Confirm:$false
        }
    }

    Context 'When updating different properties' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should update description' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.description | Should -Be 'New Description'
                return @{}
            }

            Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Description 'New Description' -Confirm:$false
        }

        It 'Should update extension_number' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.extension_number | Should -Be 5050
                return @{}
            }

            Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -ExtensionNumber 5050 -Confirm:$false
        }

        It 'Should update display_name' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.display_name | Should -Be 'New Display'
                return @{}
            }

            Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -DisplayName 'New Display' -Confirm:$false
        }

        It 'Should update multiple properties' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'New Name'
                $bodyObj.extension_number | Should -Be 5050
                return @{}
            }

            Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Name' -ExtensionNumber 5050 -Confirm:$false
        }
    }

    Context 'PassThru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should return SharedLineGroupId when PassThru is specified' {
            $result = Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Name' -PassThru -Confirm:$false
            $result | Should -Be 'slg123'
        }

        It 'Should not return API response when PassThru is specified' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'slg123'; name = 'New Name' }
            }

            $result = Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Name' -PassThru -Confirm:$false
            $result | Should -Be 'slg123'
            $result | Should -Not -BeOfType [hashtable]
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            { Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Name' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm' {
            Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Name' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept SharedLineGroupId from pipeline' {
            { 'slg123' | Update-ZoomPhoneSharedLineGroup -Name 'New Name' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept object from pipeline' {
            $slgObject = [PSCustomObject]@{
                id = 'slg123'
                Name = 'Updated Name'
            }
            { $slgObject | Update-ZoomPhoneSharedLineGroup -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept slgId alias' {
            { Update-ZoomPhoneSharedLineGroup -slgId 'slg123' -Name 'New Name' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept extension_number alias' {
            { Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -extension_number 5050 -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept display_name alias' {
            { Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -display_name 'Display' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require SharedLineGroupId parameter' {
            { Update-ZoomPhoneSharedLineGroup -Name 'New Name' -ErrorAction Stop } | Should -Throw
        }

        It 'Should throw error when no changes are provided' {
            { Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API Error')
            }

            { Update-ZoomPhoneSharedLineGroup -SharedLineGroupId 'slg123' -Name 'New Name' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
