BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomAccountBilling' {
    Context 'When getting billing information' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    first_name = 'John'
                    last_name = 'Doe'
                    email = 'john@company.com'
                    address = '123 Main St'
                    city = 'San Jose'
                    state = 'CA'
                    zip = '95131'
                    country = 'US'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomAccountBilling -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/accounts/abc123/billing'
            }
        }

        It 'Should use GET method' {
            Get-ZoomAccountBilling -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response object with billing details' {
            $result = Get-ZoomAccountBilling -AccountId 'abc123'
            $result.first_name | Should -Be 'John'
            $result.city | Should -Be 'San Jose'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ first_name = 'Test' } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ AccountId = 'abc123' } | Get-ZoomAccountBilling
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept id alias' {
            [PSCustomObject]@{ id = 'abc123' } | Get-ZoomAccountBilling
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
