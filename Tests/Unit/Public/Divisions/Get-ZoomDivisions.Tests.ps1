BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomDivisions' {
    Context 'When listing divisions' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    divisions = @(
                        @{ id = 'div1'; name = 'Division 1' }
                        @{ id = 'div2'; name = 'Division 2' }
                    )
                    total_records = 2
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomDivisions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/divisions*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomDivisions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should include page_size in query string' {
            Get-ZoomDivisions -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=50*'
            }
        }

        It 'Should include next_page_token when provided' {
            Get-ZoomDivisions -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*next_page_token=token123*'
            }
        }

        It 'Should return response object' {
            $result = Get-ZoomDivisions
            $result.divisions.Count | Should -Be 2
            $result.total_records | Should -Be 2
        }
    }

    Context 'Parameter Validation' {
        It 'Should use default PageSize of 30' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
            Get-ZoomDivisions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=30*'
            }
        }

        It 'Should accept PageSize via alias page_size' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
            Get-ZoomDivisions -page_size 100
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=100*'
            }
        }
    }
}
