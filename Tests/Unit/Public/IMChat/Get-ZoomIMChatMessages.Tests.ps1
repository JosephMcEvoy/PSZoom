BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomIMChatMessages' {
    Context 'When listing chat messages' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    messages = @(
                        @{ id = 'msg1'; message = 'Hello' }
                        @{ id = 'msg2'; message = 'World' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomIMChatMessages -UserId 'user@company.com' -SessionId 'session123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/im/users/user@company.com/chat/sessions/session123*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomIMChatMessages -UserId 'user@company.com' -SessionId 'session123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response with messages' {
            $result = Get-ZoomIMChatMessages -UserId 'user@company.com' -SessionId 'session123'
            $result.messages | Should -HaveCount 2
        }

        It 'Should accept date range parameters' {
            Get-ZoomIMChatMessages -UserId 'user@company.com' -SessionId 'session123' -From '2023-01-01' -To '2023-12-31'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*from=2023-01-01*' -and $Uri -like '*to=2023-12-31*'
            }
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ messages = @() } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ UserId = 'user@company.com'; SessionId = 'session123' } | Get-ZoomIMChatMessages
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
