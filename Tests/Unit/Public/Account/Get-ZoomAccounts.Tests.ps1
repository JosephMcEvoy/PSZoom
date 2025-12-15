BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Set up required module state within module scope
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    # Load mock response fixtures
    $script:MockAccountList = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/account-list.json" | ConvertFrom-Json
}

Describe 'Get-ZoomAccounts' {
    Context 'When listing all accounts' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountList
            }
        }

        It 'Should return account list' {
            $result = Get-ZoomAccounts
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return accounts array' {
            $result = Get-ZoomAccounts
            $result.accounts | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple accounts' {
            $result = Get-ZoomAccounts
            $result.accounts.Count | Should -BeGreaterOrEqual 1
        }

        It 'Should return total_records count' {
            $result = Get-ZoomAccounts
            $result.total_records | Should -BeGreaterOrEqual 1
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct accounts endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/accounts'
                return $script:MockAccountList
            }

            Get-ZoomAccounts
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockAccountList
            }

            Get-ZoomAccounts
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pagination parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountList
            }
        }

        It 'Should accept PageSize parameter' {
            { Get-ZoomAccounts -PageSize 50 } | Should -Not -Throw
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomAccounts -PageSize 0 } | Should -Throw
            { Get-ZoomAccounts -PageSize 301 } | Should -Throw
        }

        It 'Should accept valid PageSize at boundaries' {
            { Get-ZoomAccounts -PageSize 1 } | Should -Not -Throw
            { Get-ZoomAccounts -PageSize 300 } | Should -Not -Throw
        }

        It 'Should accept NextPageToken parameter' {
            { Get-ZoomAccounts -NextPageToken 'abc123token' } | Should -Not -Throw
        }

        It 'Should include page_size in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'page_size='
                return $script:MockAccountList
            }

            Get-ZoomAccounts -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include next_page_token in query string when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'next_page_token=testtoken'
                return $script:MockAccountList
            }

            Get-ZoomAccounts -NextPageToken 'testtoken'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountList
            }
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomAccounts -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomAccounts -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Default parameter values' {
        It 'Should use default PageSize of 30' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'page_size=30'
                return $script:MockAccountList
            }

            Get-ZoomAccounts
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Get-ZoomAccounts -ErrorAction Stop } | Should -Throw
        }
    }
}
