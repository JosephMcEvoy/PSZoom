BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomContactGroupMembers' {
    Context 'When listing contact group members' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    group_members = @(
                        @{ type = 1; id = 'user1'; name = 'John Doe' }
                        @{ type = 1; id = 'user2'; name = 'Jane Doe' }
                    )
                    page_size = 10
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomContactGroupMembers -GroupId 'grp123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/contacts/groups/grp123/members*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomContactGroupMembers -GroupId 'grp123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return members' {
            $result = Get-ZoomContactGroupMembers -GroupId 'grp123'
            $result.group_members | Should -HaveCount 2
        }

        It 'Should include page_size in query' {
            Get-ZoomContactGroupMembers -GroupId 'grp123' -PageSize 25
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=25*'
            }
        }

        It 'Should include next_page_token when specified' {
            Get-ZoomContactGroupMembers -GroupId 'grp123' -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*next_page_token=token123*'
            }
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ group_members = @() } }
        }

        It 'Should accept GroupId from pipeline' {
            'grp123' | Get-ZoomContactGroupMembers
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
