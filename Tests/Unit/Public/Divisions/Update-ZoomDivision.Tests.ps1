BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomDivision' {
    Context 'When updating a division' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomDivision -DivisionId 'div123' -DivisionName 'Updated Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/divisions/div123*'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomDivision -DivisionId 'div123' -DivisionName 'Updated Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should include division_name in body when provided' {
            Update-ZoomDivision -DivisionId 'div123' -DivisionName 'Updated Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.division_name -eq 'Updated Name'
            }
        }

        It 'Should include division_description in body when provided' {
            Update-ZoomDivision -DivisionId 'div123' -DivisionDescription 'Updated description'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.division_description -eq 'Updated description'
            }
        }

        It 'Should not call API when no updates provided' {
            Update-ZoomDivision -DivisionId 'div123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should return true on success' {
            $result = Update-ZoomDivision -DivisionId 'div123' -DivisionName 'Updated'
            $result | Should -Be $true
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should accept pipeline input by value' {
            'div123' | Update-ZoomDivision -DivisionName 'Updated'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ DivisionId = 'div123'; DivisionName = 'Updated' } | Update-ZoomDivision
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
