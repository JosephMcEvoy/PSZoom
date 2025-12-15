BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneSettingTemplate' {
    Context 'When retrieving all setting templates' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'setting-template-123'
                        name = 'Standard Settings'
                        site_id = 'site-001'
                    }
                    @{
                        id = 'setting-template-456'
                        name = 'Advanced Settings'
                        site_id = 'site-002'
                    }
                )
            }
        }

        It 'Should return setting templates' {
            $result = Get-ZoomPhoneSettingTemplate
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple templates' {
            $result = Get-ZoomPhoneSettingTemplate
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/setting_templates'
                return @()
            }

            Get-ZoomPhoneSettingTemplate
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }

        It 'Should use default PageSize of 100' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($PageSize)
                $PageSize | Should -Be 100
                return @()
            }

            Get-ZoomPhoneSettingTemplate
        }
    }

    Context 'When retrieving specific setting template by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'setting-template-123'
                        name = 'Standard Settings'
                    }
                )
            }
        }

        It 'Should accept templateId parameter' {
            $result = Get-ZoomPhoneSettingTemplate -templateId 'setting-template-123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be 'setting-template-123'
                return @()
            }

            Get-ZoomPhoneSettingTemplate -templateId 'setting-template-123'
        }

        It 'Should accept multiple templateIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneSettingTemplate -templateId 'setting-template-123', 'setting-template-456'
        }
    }

    Context 'When filtering by SiteId' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'setting-template-123'
                        site_id = 'site-001'
                    }
                )
            }
        }

        It 'Should accept SiteId parameter' {
            $result = Get-ZoomPhoneSettingTemplate -SiteId 'site-001'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass site_id query statement' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['site_id'] | Should -Be 'site-001'
                return @()
            }

            Get-ZoomPhoneSettingTemplate -SiteId 'site-001'
        }

        It 'Should handle multiple SiteIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }

            Get-ZoomPhoneSettingTemplate -SiteId 'site-001', 'site-002'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 2
        }

        It 'Should support Full parameter with SiteId' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @( @{ id = 'setting-template-123' } )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @()
            }

            Get-ZoomPhoneSettingTemplate -SiteId 'site-001' -Full
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

            Get-ZoomPhoneSettingTemplate -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneSettingTemplate -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneSettingTemplate -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'setting-template-123' }
                    @{ id = 'setting-template-456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'setting-template-123'; details = 'full' }
                    @{ id = 'setting-template-456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneSettingTemplate -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should extract IDs from initial response' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($ObjectIds)
                $ObjectIds | Should -Contain 'setting-template-123'
                $ObjectIds | Should -Contain 'setting-template-456'
                return @()
            }

            Get-ZoomPhoneSettingTemplate -Full
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneSettingTemplate'
                return @()
            }

            Get-ZoomPhoneSettingTemplate -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept templateId from pipeline' {
            # Note: Raw string pipeline input is ambiguous due to multiple ValueFromPipeline parameters
            # Use PSCustomObject with templateId property for unambiguous binding
            { [PSCustomObject]@{ templateId = 'setting-template-123' } | Get-ZoomPhoneSettingTemplate } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $templateObject = [PSCustomObject]@{ id = 'setting-template-123' }
            { $templateObject | Get-ZoomPhoneSettingTemplate } | Should -Not -Throw
        }

        It 'Should accept object with template_Id property from pipeline' {
            $templateObject = [PSCustomObject]@{ template_Id = 'setting-template-123' }
            { $templateObject | Get-ZoomPhoneSettingTemplate } | Should -Not -Throw
        }

        It 'Should accept SiteId from pipeline' {
            { 'site-001' | Get-ZoomPhoneSettingTemplate -SiteId { $_ } } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for templateId' {
            { Get-ZoomPhoneSettingTemplate -id 'setting-template-123' } | Should -Not -Throw
        }

        It 'Should accept template_Id alias for templateId' {
            { Get-ZoomPhoneSettingTemplate -template_Id 'setting-template-123' } | Should -Not -Throw
        }

        It 'Should accept site_id alias for SiteId' {
            { Get-ZoomPhoneSettingTemplate -site_id 'site-001' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneSettingTemplate -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneSettingTemplate -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept templateId as first positional parameter' {
            { Get-ZoomPhoneSettingTemplate 'setting-template-123' } | Should -Not -Throw
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneSettingsTemplates alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneSettingsTemplates' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneSettingTemplate'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Setting template not found')
            }

            { Get-ZoomPhoneSettingTemplate -templateId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
