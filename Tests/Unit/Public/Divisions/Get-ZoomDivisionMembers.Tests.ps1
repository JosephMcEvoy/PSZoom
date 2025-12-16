BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomDivisionMembers' {
    Context 'When listing division members' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    users = @(
                        @{ id = 'user1'; email = 'user1@test.com' }
                        @{ id = 'user2'; email = 'user2@test.com' }
                    )
                    total_records = 2
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomDivisionMembers -DivisionId 'div123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/divisions/div123/users*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomDivisionMembers -DivisionId 'div123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should include page_size in query string' {
            Get-ZoomDivisionMembers -DivisionId 'div123' -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=50*'
            }
        }

        It 'Should include next_page_token when provided' {
            Get-ZoomDivisionMembers -DivisionId 'div123' -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*next_page_token=token123*'
            }
        }

        It 'Should return response object' {
            $result = Get-ZoomDivisionMembers -DivisionId 'div123'
            $result.users.Count | Should -Be 2
            $result.total_records | Should -Be 2
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ users = @() } }
        }

        It 'Should accept pipeline input by value' {
            'div123' | Get-ZoomDivisionMembers
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ DivisionId = 'div123' } | Get-ZoomDivisionMembers
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
