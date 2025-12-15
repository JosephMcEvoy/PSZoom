BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomIMGroups' {
    Context 'When listing IM groups' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    groups = @(
                        @{ id = 'group1'; name = 'Engineering' }
                        @{ id = 'group2'; name = 'Sales' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomIMGroups
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/im/groups*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomIMGroups
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response with groups' {
            $result = Get-ZoomIMGroups
            $result.groups | Should -HaveCount 2
        }

        It 'Should accept PageSize parameter' {
            Get-ZoomIMGroups -PageSize 100
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=100*'
            }
        }
    }
}
