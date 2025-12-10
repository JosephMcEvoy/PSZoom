BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomIMChatSessions' {
    Context 'When listing chat sessions' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    sessions = @(
                        @{ session_id = 'session1'; name = 'Chat 1' }
                        @{ session_id = 'session2'; name = 'Chat 2' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomIMChatSessions -UserId 'user@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/im/users/user@company.com/chat/sessions*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomIMChatSessions -UserId 'user@company.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response with sessions' {
            $result = Get-ZoomIMChatSessions -UserId 'user@company.com'
            $result.sessions | Should -HaveCount 2
        }

        It 'Should accept date range parameters' {
            Get-ZoomIMChatSessions -UserId 'user@company.com' -From '2023-01-01' -To '2023-12-31'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*from=2023-01-01*' -and $Uri -like '*to=2023-12-31*'
            }
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ sessions = @() } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ UserId = 'user@company.com' } | Get-ZoomIMChatSessions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
