BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomIMGroupMembers' {
    Context 'When listing IM group members' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    members = @(
                        @{ id = 'user1'; email = 'user1@company.com' }
                        @{ id = 'user2'; email = 'user2@company.com' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomIMGroupMembers -GroupId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/im/groups/abc123/members*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomIMGroupMembers -GroupId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response with members' {
            $result = Get-ZoomIMGroupMembers -GroupId 'abc123'
            $result.members | Should -HaveCount 2
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ members = @() } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ GroupId = 'abc123' } | Get-ZoomIMGroupMembers
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
