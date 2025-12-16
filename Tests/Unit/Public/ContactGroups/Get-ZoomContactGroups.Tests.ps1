BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomContactGroups' {
    Context 'When listing contact groups' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    groups = @(
                        @{ group_id = 'grp1'; group_name = 'Team A' }
                        @{ group_id = 'grp2'; group_name = 'Team B' }
                    )
                    page_size = 10
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomContactGroups
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/contacts/groups*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomContactGroups
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return groups' {
            $result = Get-ZoomContactGroups
            $result.groups | Should -HaveCount 2
        }

        It 'Should include page_size in query' {
            Get-ZoomContactGroups -PageSize 25
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=25*'
            }
        }

        It 'Should include next_page_token when specified' {
            Get-ZoomContactGroups -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*next_page_token=token123*'
            }
        }
    }
}
