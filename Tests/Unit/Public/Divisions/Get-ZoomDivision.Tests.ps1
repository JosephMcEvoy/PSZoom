BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomDivision' {
    Context 'When getting a specific division' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'div123'
                    name = 'Test Division'
                    description = 'A test division'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomDivision -DivisionId 'div123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/divisions/div123*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomDivision -DivisionId 'div123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return division details' {
            $result = Get-ZoomDivision -DivisionId 'div123'
            $result.id | Should -Be 'div123'
            $result.name | Should -Be 'Test Division'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'div123' } }
        }

        It 'Should accept pipeline input by value' {
            'div123' | Get-ZoomDivision
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ DivisionId = 'div123' } | Get-ZoomDivision
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept pipeline input with alias id' {
            [PSCustomObject]@{ id = 'div123' } | Get-ZoomDivision
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
