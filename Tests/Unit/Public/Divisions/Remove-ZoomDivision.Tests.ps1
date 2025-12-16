BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomDivision' {
    Context 'When deleting a division' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomDivision -DivisionId 'div123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/divisions/div123*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomDivision -DivisionId 'div123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should return true on success' {
            $result = Remove-ZoomDivision -DivisionId 'div123' -Confirm:$false
            $result | Should -Be $true
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should not call API when -WhatIf is specified' {
            Remove-ZoomDivision -DivisionId 'div123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should call API when -Confirm:$false is specified' {
            Remove-ZoomDivision -DivisionId 'div123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should accept pipeline input by value' {
            'div123' | Remove-ZoomDivision -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ DivisionId = 'div123' } | Remove-ZoomDivision -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
