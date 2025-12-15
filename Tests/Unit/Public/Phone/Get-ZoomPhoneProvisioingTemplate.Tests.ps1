BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneProvisioingTemplate' {
    Context 'When retrieving all provisioning templates' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'template123'
                        name = 'Standard Template'
                        type = 1
                    }
                    @{
                        id = 'template456'
                        name = 'Executive Template'
                        type = 2
                    }
                )
            }
        }

        It 'Should return provisioning templates' {
            $result = Get-ZoomPhoneProvisioingTemplate
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple templates' {
            $result = Get-ZoomPhoneProvisioingTemplate
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/provision_templates'
                return @()
            }

            Get-ZoomPhoneProvisioingTemplate
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }

        It 'Should use default PageSize of 30' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($PageSize)
                $PageSize | Should -Be 30
                return @()
            }

            Get-ZoomPhoneProvisioingTemplate
        }
    }

    Context 'When retrieving specific provisioning template by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'template123'
                        name = 'Standard Template'
                    }
                )
            }
        }

        It 'Should accept ProvisionTemplateID parameter' {
            $result = Get-ZoomPhoneProvisioingTemplate -ProvisionTemplateID 'template123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be 'template123'
                return @()
            }

            Get-ZoomPhoneProvisioingTemplate -ProvisionTemplateID 'template123'
        }

        It 'Should accept multiple ProvisionTemplateIDs' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneProvisioingTemplate -ProvisionTemplateID 'template123', 'template456'
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

            Get-ZoomPhoneProvisioingTemplate -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneProvisioingTemplate -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneProvisioingTemplate -PageSize 150 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate PageSize minimum' {
            { Get-ZoomPhoneProvisioingTemplate -PageSize 0 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'template123' }
                    @{ id = 'template456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'template123'; details = 'full' }
                    @{ id = 'template456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneProvisioingTemplate -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should extract IDs from initial response' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($ObjectIds)
                $ObjectIds | Should -Contain 'template123'
                $ObjectIds | Should -Contain 'template456'
                return @()
            }

            Get-ZoomPhoneProvisioingTemplate -Full
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneProvisioingTemplate'
                return @()
            }

            Get-ZoomPhoneProvisioingTemplate -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept ProvisionTemplateID from pipeline' {
            { 'template123' | Get-ZoomPhoneProvisioingTemplate } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $templateObject = [PSCustomObject]@{ id = 'template123' }
            { $templateObject | Get-ZoomPhoneProvisioingTemplate } | Should -Not -Throw
        }

        It 'Should accept object with common_Area_Id property from pipeline' {
            $templateObject = [PSCustomObject]@{ common_Area_Id = 'template123' }
            { $templateObject | Get-ZoomPhoneProvisioingTemplate } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for ProvisionTemplateID' {
            { Get-ZoomPhoneProvisioingTemplate -id 'template123' } | Should -Not -Throw
        }

        It 'Should accept common_Area_Id alias for ProvisionTemplateID' {
            { Get-ZoomPhoneProvisioingTemplate -common_Area_Id 'template123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneProvisioingTemplate -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneProvisioingTemplate -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept ProvisionTemplateID as first positional parameter' {
            { Get-ZoomPhoneProvisioingTemplate 'template123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Template not found')
            }

            { Get-ZoomPhoneProvisioingTemplate -ProvisionTemplateID 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
