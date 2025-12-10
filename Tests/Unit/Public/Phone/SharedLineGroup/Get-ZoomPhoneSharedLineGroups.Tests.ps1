BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneSharedLineGroups' {
    Context 'When retrieving all shared line groups' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'slg123'
                        name = 'Sales Team'
                        extension_number = 5001
                    }
                    @{
                        id = 'slg456'
                        name = 'Support Team'
                        extension_number = 5002
                    }
                )
            }
        }

        It 'Should return shared line groups' {
            $result = Get-ZoomPhoneSharedLineGroups
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple shared line groups' {
            $result = Get-ZoomPhoneSharedLineGroups
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/shared_line_groups'
                return @()
            }

            Get-ZoomPhoneSharedLineGroups
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }
    }

    Context 'When using pagination parameters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept PageSize parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($PageSize)
                $PageSize | Should -Be 50
                return @()
            }

            Get-ZoomPhoneSharedLineGroups -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneSharedLineGroups -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneSharedLineGroups -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When filtering by site' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept SiteId parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['site_id'] | Should -Be 'site123'
                return @()
            }

            Get-ZoomPhoneSharedLineGroups -SiteId 'site123'
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'slg123' }
                    @{ id = 'slg456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'slg123'; details = 'full' }
                    @{ id = 'slg456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneSharedLineGroups -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneSharedLineGroup'
                return @()
            }

            Get-ZoomPhoneSharedLineGroups -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept SiteId from pipeline' {
            { 'site123' | Get-ZoomPhoneSharedLineGroups } | Should -Not -Throw
        }

        It 'Should accept object with site_id property from pipeline' {
            $siteObject = [PSCustomObject]@{ site_id = 'site123' }
            { $siteObject | Get-ZoomPhoneSharedLineGroups } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept site_id alias for SiteId' {
            { Get-ZoomPhoneSharedLineGroups -site_id 'site123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneSharedLineGroups -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneSharedLineGroups -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Shared line group not found')
            }

            { Get-ZoomPhoneSharedLineGroups -ErrorAction Stop } | Should -Throw
        }
    }
}
