BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneExternalContacts' {
    Context 'When retrieving all external contacts' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'contact123'
                        first_name = 'John'
                        last_name = 'Doe'
                        phone_number = '+14155551234'
                    }
                    @{
                        id = 'contact456'
                        first_name = 'Jane'
                        last_name = 'Smith'
                        phone_number = '+14155555678'
                    }
                )
            }
        }

        It 'Should return external contacts' {
            $result = Get-ZoomPhoneExternalContacts
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple external contacts' {
            $result = Get-ZoomPhoneExternalContacts
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/external_contacts'
                return @()
            }

            Get-ZoomPhoneExternalContacts
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

            Get-ZoomPhoneExternalContacts -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneExternalContacts -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneExternalContacts -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneExternalContacts -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneExternalContacts -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('External contacts not found')
            }

            { Get-ZoomPhoneExternalContacts -ErrorAction Stop } | Should -Throw
        }
    }
}
