BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneSiteEmergencyAddress' {
    Context 'When retrieving all emergency addresses' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'addr-123'
                        address_line1 = '123 Main St'
                        city = 'New York'
                        state_code = 'NY'
                        zip = '10001'
                    }
                    @{
                        id = 'addr-456'
                        address_line1 = '456 West Ave'
                        city = 'Los Angeles'
                        state_code = 'CA'
                        zip = '90001'
                    }
                )
            }
        }

        It 'Should return emergency addresses' {
            $result = Get-ZoomPhoneSiteEmergencyAddress
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple addresses' {
            $result = Get-ZoomPhoneSiteEmergencyAddress
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/emergency_addresses'
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }

        It 'Should use default PageSize of 100' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($PageSize)
                $PageSize | Should -Be 100
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress
        }
    }

    Context 'When retrieving specific emergency address by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'addr-123'
                        address_line1 = '123 Main St'
                    }
                )
            }
        }

        It 'Should accept EmergencyAddressId parameter' {
            $result = Get-ZoomPhoneSiteEmergencyAddress -EmergencyAddressId 'addr-123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be 'addr-123'
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress -EmergencyAddressId 'addr-123'
        }

        It 'Should accept multiple EmergencyAddressIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress -EmergencyAddressId 'addr-123', 'addr-456'
        }
    }

    Context 'When filtering by SiteId' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'addr-123'
                        site_id = 'site-001'
                    }
                )
            }
        }

        It 'Should accept SiteId parameter' {
            $result = Get-ZoomPhoneSiteEmergencyAddress -SiteId 'site-001'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass site_id query statement' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['site_id'] | Should -Be 'site-001'
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress -SiteId 'site-001'
        }

        It 'Should handle multiple SiteIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress -SiteId 'site-001', 'site-002'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 2
        }

        It 'Should support Full parameter with SiteId' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @( @{ id = 'addr-123' } )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress -SiteId 'site-001' -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
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

            Get-ZoomPhoneSiteEmergencyAddress -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneSiteEmergencyAddress -PageSize 150 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate PageSize minimum' {
            { Get-ZoomPhoneSiteEmergencyAddress -PageSize 0 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'addr-123' }
                    @{ id = 'addr-456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'addr-123'; details = 'full' }
                    @{ id = 'addr-456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneSiteEmergencyAddress -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should extract IDs from initial response' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($ObjectIds)
                $ObjectIds | Should -Contain 'addr-123'
                $ObjectIds | Should -Contain 'addr-456'
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress -Full
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneSiteEmergencyAddress'
                return @()
            }

            Get-ZoomPhoneSiteEmergencyAddress -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept EmergencyAddressId from pipeline' {
            { 'addr-123' | Get-ZoomPhoneSiteEmergencyAddress } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $addressObject = [PSCustomObject]@{ id = 'addr-123' }
            { $addressObject | Get-ZoomPhoneSiteEmergencyAddress } | Should -Not -Throw
        }

        It 'Should accept object with Emergency_Address_Id property from pipeline' {
            $addressObject = [PSCustomObject]@{ Emergency_Address_Id = 'addr-123' }
            { $addressObject | Get-ZoomPhoneSiteEmergencyAddress } | Should -Not -Throw
        }

        It 'Should accept SiteId from pipeline' {
            $siteObject = [PSCustomObject]@{ site_id = 'site-001' }
            { $siteObject | Get-ZoomPhoneSiteEmergencyAddress -SiteId { $_.site_id } } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for EmergencyAddressId' {
            { Get-ZoomPhoneSiteEmergencyAddress -id 'addr-123' } | Should -Not -Throw
        }

        It 'Should accept Emergency_Address_Id alias for EmergencyAddressId' {
            { Get-ZoomPhoneSiteEmergencyAddress -Emergency_Address_Id 'addr-123' } | Should -Not -Throw
        }

        It 'Should accept site_id alias for SiteId' {
            { Get-ZoomPhoneSiteEmergencyAddress -site_id 'site-001' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneSiteEmergencyAddress -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneSiteEmergencyAddress -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept EmergencyAddressId as first positional parameter' {
            { Get-ZoomPhoneSiteEmergencyAddress 'addr-123' } | Should -Not -Throw
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneSiteEmergencyAddresses alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneSiteEmergencyAddresses' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneSiteEmergencyAddress'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Emergency address not found')
            }

            { Get-ZoomPhoneSiteEmergencyAddress -EmergencyAddressId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
