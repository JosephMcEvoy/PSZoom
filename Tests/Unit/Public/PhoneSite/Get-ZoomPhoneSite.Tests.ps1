BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneSite' {
    Context 'When retrieving all phone sites' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'site-123'
                        name = 'New York Office'
                        address = '123 Main St'
                    }
                    @{
                        id = 'site-456'
                        name = 'Los Angeles Office'
                        address = '456 West Ave'
                    }
                )
            }
        }

        It 'Should return phone sites' {
            $result = Get-ZoomPhoneSite
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple sites' {
            $result = Get-ZoomPhoneSite
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/sites'
                return @()
            }

            Get-ZoomPhoneSite
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }

        It 'Should use default PageSize of 100' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($PageSize)
                $PageSize | Should -Be 100
                return @()
            }

            Get-ZoomPhoneSite
        }
    }

    Context 'When retrieving specific phone site by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'site-123'
                        name = 'New York Office'
                    }
                )
            }
        }

        It 'Should accept SiteId parameter' {
            $result = Get-ZoomPhoneSite -SiteId 'site-123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be 'site-123'
                return @()
            }

            Get-ZoomPhoneSite -SiteId 'site-123'
        }

        It 'Should accept multiple SiteIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneSite -SiteId 'site-123', 'site-456'
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

            Get-ZoomPhoneSite -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneSite -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneSite -PageSize 150 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate PageSize minimum' {
            { Get-ZoomPhoneSite -PageSize 0 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'site-123' }
                    @{ id = 'site-456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'site-123'; details = 'full' }
                    @{ id = 'site-456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneSite -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should extract IDs from initial response' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($ObjectIds)
                $ObjectIds | Should -Contain 'site-123'
                $ObjectIds | Should -Contain 'site-456'
                return @()
            }

            Get-ZoomPhoneSite -Full
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneSite'
                return @()
            }

            Get-ZoomPhoneSite -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept SiteId from pipeline' {
            { 'site-123' | Get-ZoomPhoneSite } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $siteObject = [PSCustomObject]@{ id = 'site-123' }
            { $siteObject | Get-ZoomPhoneSite } | Should -Not -Throw
        }

        It 'Should accept object with site_id property from pipeline' {
            $siteObject = [PSCustomObject]@{ site_id = 'site-123' }
            { $siteObject | Get-ZoomPhoneSite } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for SiteId' {
            { Get-ZoomPhoneSite -id 'site-123' } | Should -Not -Throw
        }

        It 'Should accept site_id alias for SiteId' {
            { Get-ZoomPhoneSite -site_id 'site-123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneSite -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneSite -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept SiteId as first positional parameter' {
            { Get-ZoomPhoneSite 'site-123' } | Should -Not -Throw
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneSites alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneSites' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneSite'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Site not found')
            }

            { Get-ZoomPhoneSite -SiteId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
