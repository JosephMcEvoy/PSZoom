BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Send-ZoomChatbotUnfurl' {
    Context 'When sending a link unfurl' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null  # API returns 204 No Content
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI including user and trigger IDs' {
            Send-ZoomChatbotUnfurl -UserId 'user123' -TriggerId 'trigger456' -Content '{"title":"Test"}'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/im/chat/users/user123/unfurls/trigger456'
            }
        }

        It 'Should use POST method' {
            Send-ZoomChatbotUnfurl -UserId 'user123' -TriggerId 'trigger456' -Content '{"title":"Test"}'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should include content in body' {
            Send-ZoomChatbotUnfurl -UserId 'user123' -TriggerId 'trigger456' -Content '{"title":"Test"}'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.content -eq '{"title":"Test"}'
            }
        }

        It 'Should return true when API returns no content' {
            $result = Send-ZoomChatbotUnfurl -UserId 'user123' -TriggerId 'trigger456' -Content '{"title":"Test"}'
            $result | Should -Be $true
        }
    }

    Context 'When API returns a response' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should return API response when present' {
            $result = Send-ZoomChatbotUnfurl -UserId 'user123' -TriggerId 'trigger456' -Content '{"title":"Test"}'
            $result.status | Should -Be 'success'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{
                UserId    = 'user123'
                TriggerId = 'trigger456'
                Content   = '{"title":"Test"}'
            } | Send-ZoomChatbotUnfurl
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept snake_case aliases from pipeline' {
            [PSCustomObject]@{
                user_id    = 'user123'
                trigger_id = 'trigger456'
                Content    = '{"title":"Test"}'
            } | Send-ZoomChatbotUnfurl
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
