BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomChatbotMessage' {
    Context 'When updating a chatbot message' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    message_id = 'msg123'
                    robot_jid  = 'bot@xmpp.zoom.us'
                    sent_time  = '2025-01-01T00:00:00Z'
                    to_jid     = 'channel@conference.xmpp.zoom.us'
                    user_jid   = 'user@xmpp.zoom.us'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI including message ID' {
            $content = @{ head = @{ text = 'Updated' } }
            Update-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Content $content
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/im/chat/messages/msg123'
            }
        }

        It 'Should use PUT method' {
            $content = @{ head = @{ text = 'Updated' } }
            Update-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Content $content
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Put'
            }
        }

        It 'Should include required parameters in body' {
            $content = @{ head = @{ text = 'Updated' } }
            Update-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Content $content
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.robot_jid -eq 'bot@xmpp.zoom.us' -and
                $Body.account_id -eq 'abc123' -and
                $Body.content -ne $null
            }
        }

        It 'Should return response with message_id' {
            $content = @{ head = @{ text = 'Updated' } }
            $result = Update-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Content $content
            $result.message_id | Should -Be 'msg123'
        }
    }

    Context 'When using optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ message_id = 'msg123' } }
        }

        It 'Should include user_jid when specified' {
            $content = @{ head = @{ text = 'Updated' } }
            Update-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Content $content -UserJid 'user@xmpp.zoom.us'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.user_jid -eq 'user@xmpp.zoom.us'
            }
        }

        It 'Should include is_markdown_support when switch is set' {
            $content = @{ head = @{ text = 'Updated' } }
            Update-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Content $content -IsMarkdownSupport
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.is_markdown_support -eq $true
            }
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ message_id = 'msg123' } }
        }

        It 'Should accept MessageId from pipeline' {
            $content = @{ head = @{ text = 'Updated' } }
            'msg123' | Update-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Content $content
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*msg123*'
            }
        }

        It 'Should accept pipeline input by property name' {
            $content = @{ head = @{ text = 'Updated' } }
            [PSCustomObject]@{
                MessageId = 'msg123'
                RobotJid  = 'bot@xmpp.zoom.us'
                AccountId = 'abc123'
                Content   = $content
            } | Update-ZoomChatbotMessage
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept message_id alias from pipeline' {
            $content = @{ head = @{ text = 'Updated' } }
            [PSCustomObject]@{
                message_id = 'msg123'
                robot_jid  = 'bot@xmpp.zoom.us'
                account_id = 'abc123'
                Content    = $content
            } | Update-ZoomChatbotMessage
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
