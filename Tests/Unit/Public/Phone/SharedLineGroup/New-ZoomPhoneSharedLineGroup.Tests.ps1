BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomPhoneSharedLineGroup' {
    Context 'When creating a shared line group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'slg123'
                    name = 'Sales Team'
                    extension_number = 5001
                }
            }
        }

        It 'Should create a shared line group with required parameters' {
            $result = New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'slg123'
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/shared_line_groups'
                return @{ id = 'slg123' }
            }

            New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{ id = 'slg123' }
            }

            New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -Confirm:$false
        }

        It 'Should include name in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'Sales Team'
                return @{ id = 'slg123' }
            }

            New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -Confirm:$false
        }

        It 'Should include extension_number in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.extension_number | Should -Be 5001
                return @{ id = 'slg123' }
            }

            New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -Confirm:$false
        }
    }

    Context 'When creating with optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'slg123' }
            }
        }

        It 'Should include description when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.description | Should -Be 'Sales team line'
                return @{ id = 'slg123' }
            }

            New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -Description 'Sales team line' -Confirm:$false
        }

        It 'Should include site_id when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.site_id | Should -Be 'site123'
                return @{ id = 'slg123' }
            }

            New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -SiteId 'site123' -Confirm:$false
        }

        It 'Should include display_name when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.display_name | Should -Be 'Sales Display'
                return @{ id = 'slg123' }
            }

            New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -DisplayName 'Sales Display' -Confirm:$false
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'slg123' }
            }
        }

        It 'Should support WhatIf' {
            { New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'slg123' }
            }

            New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'slg123' }
            }
        }

        It 'Should accept extension_number alias' {
            { New-ZoomPhoneSharedLineGroup -Name 'Sales' -extension_number 5001 -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept site_id alias' {
            { New-ZoomPhoneSharedLineGroup -Name 'Sales' -ExtensionNumber 5001 -site_id 'site123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept display_name alias' {
            { New-ZoomPhoneSharedLineGroup -Name 'Sales' -ExtensionNumber 5001 -display_name 'Display' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require Name parameter' {
            { New-ZoomPhoneSharedLineGroup -ExtensionNumber 5001 -ErrorAction Stop } | Should -Throw
        }

        It 'Should require ExtensionNumber parameter' {
            { New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API Error')
            }

            { New-ZoomPhoneSharedLineGroup -Name 'Sales Team' -ExtensionNumber 5001 -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
