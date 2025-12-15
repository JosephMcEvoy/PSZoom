BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomAccountManagedDomains' {
    Context 'When getting managed domains' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    domains = @(
                        @{ domain = 'company.com'; status = 'approved' }
                        @{ domain = 'test.com'; status = 'pending' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomAccountManagedDomains -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/accounts/abc123/managed_domains'
            }
        }

        It 'Should use GET method' {
            Get-ZoomAccountManagedDomains -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response object' {
            $result = Get-ZoomAccountManagedDomains -AccountId 'abc123'
            $result.domains | Should -HaveCount 2
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ domains = @() } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ AccountId = 'abc123' } | Get-ZoomAccountManagedDomains
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept id alias' {
            [PSCustomObject]@{ id = 'abc123' } | Get-ZoomAccountManagedDomains
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
