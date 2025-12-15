BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomAccountBilling' {
    Context 'When updating billing information' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomAccountBilling -AccountId 'abc123' -FirstName 'John'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/accounts/abc123/billing*'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomAccountBilling -AccountId 'abc123' -FirstName 'John'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should not call API when no optional parameters provided' {
            Update-ZoomAccountBilling -AccountId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should accept multiple billing fields' {
            Update-ZoomAccountBilling -AccountId 'abc123' -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -City 'San Jose' -State 'CA'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ AccountId = 'abc123'; FirstName = 'John' } | Update-ZoomAccountBilling
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
