BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Set up required module state within module scope
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    # Load mock response fixtures
    $script:MockAccountGet = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/account-get.json" | ConvertFrom-Json
}

Describe 'Get-ZoomAccount' {
    Context 'When retrieving account details' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountGet
            }
        }

        It 'Should return account details' {
            $result = Get-ZoomAccount -AccountId 'EABcdEFghiJKLM'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return account with correct id' {
            $result = Get-ZoomAccount -AccountId 'EABcdEFghiJKLM'
            $result.id | Should -Be 'EABcdEFghiJKLM'
        }

        It 'Should return account with owner email' {
            $result = Get-ZoomAccount -AccountId 'EABcdEFghiJKLM'
            $result.owner_email | Should -Be 'admin@example.com'
        }

        It 'Should return account with options' {
            $result = Get-ZoomAccount -AccountId 'EABcdEFghiJKLM'
            $result.options | Should -Not -BeNullOrEmpty
            $result.options.share_rc | Should -BeTrue
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct account endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/accounts/'
                return $script:MockAccountGet
            }

            Get-ZoomAccount -AccountId 'testaccount123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockAccountGet
            }

            Get-ZoomAccount -AccountId 'EABcdEFghiJKLM'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountGet
            }
        }

        It 'Should accept AccountId from pipeline' {
            $result = 'EABcdEFghiJKLM' | Get-ZoomAccount
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with id property from pipeline' {
            $accountObject = [PSCustomObject]@{ id = 'EABcdEFghiJKLM' }
            $result = $accountObject | Get-ZoomAccount
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountGet
            }
        }

        It 'Should accept account_id alias for AccountId' {
            { Get-ZoomAccount -account_id 'testaccount' } | Should -Not -Throw
        }

        It 'Should accept id alias for AccountId' {
            { Get-ZoomAccount -id 'testaccount' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockAccountGet
            }
        }

        It 'Should accept AccountId as first positional parameter' {
            $result = Get-ZoomAccount 'EABcdEFghiJKLM'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Account not found')
            }

            { Get-ZoomAccount -AccountId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
