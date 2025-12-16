BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomDivision' {
    Context 'When creating a division' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'newdiv123'
                    name = 'New Division'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomDivision -DivisionName 'New Division'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/divisions*'
            }
        }

        It 'Should use POST method' {
            New-ZoomDivision -DivisionName 'New Division'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should include division_name in body' {
            New-ZoomDivision -DivisionName 'New Division'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.division_name -eq 'New Division'
            }
        }

        It 'Should include division_description when provided' {
            New-ZoomDivision -DivisionName 'New Division' -DivisionDescription 'Test description'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.division_name -eq 'New Division' -and
                $Body.division_description -eq 'Test description'
            }
        }

        It 'Should return response object' {
            $result = New-ZoomDivision -DivisionName 'New Division'
            $result.id | Should -Be 'newdiv123'
            $result.name | Should -Be 'New Division'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'div123' } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ DivisionName = 'Test' } | New-ZoomDivision
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept pipeline input with alias name' {
            [PSCustomObject]@{ name = 'Test' } | New-ZoomDivision
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
