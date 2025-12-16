BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Send-ZoomChatbotMessage' {
    Context 'When sending a chatbot message' {
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

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            $content = @{ head = @{ text = 'Test' } }
            Send-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -ToJid 'channel@conference.xmpp.zoom.us' -AccountId 'abc123' -UserJid 'user@xmpp.zoom.us' -Content $content
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/im/chat/messages'
            }
        }

        It 'Should use POST method' {
            $content = @{ head = @{ text = 'Test' } }
            Send-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -ToJid 'channel@conference.xmpp.zoom.us' -AccountId 'abc123' -UserJid 'user@xmpp.zoom.us' -Content $content
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should include required parameters in body' {
            $content = @{ head = @{ text = 'Test' } }
            Send-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -ToJid 'channel@conference.xmpp.zoom.us' -AccountId 'abc123' -UserJid 'user@xmpp.zoom.us' -Content $content
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.robot_jid -eq 'bot@xmpp.zoom.us' -and
                $Body.to_jid -eq 'channel@conference.xmpp.zoom.us' -and
                $Body.account_id -eq 'abc123' -and
                $Body.user_jid -eq 'user@xmpp.zoom.us' -and
                $Body.content -ne $null
            }
        }

        It 'Should return response with message_id' {
            $content = @{ head = @{ text = 'Test' } }
            $result = Send-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -ToJid 'channel@conference.xmpp.zoom.us' -AccountId 'abc123' -UserJid 'user@xmpp.zoom.us' -Content $content
            $result.message_id | Should -Be 'msg123'
        }
    }

    Context 'When using optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ message_id = 'msg123' } }
        }

        It 'Should include visible_to_user when specified' {
            $content = @{ head = @{ text = 'Test' } }
            Send-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -ToJid 'channel@conference.xmpp.zoom.us' -AccountId 'abc123' -UserJid 'user@xmpp.zoom.us' -Content $content -VisibleToUser 'specificuser123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.visible_to_user -eq 'specificuser123'
            }
        }

        It 'Should include reply_to when specified' {
            $content = @{ head = @{ text = 'Test' } }
            Send-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -ToJid 'channel@conference.xmpp.zoom.us' -AccountId 'abc123' -UserJid 'user@xmpp.zoom.us' -Content $content -ReplyTo 'parentmsg456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.reply_to -eq 'parentmsg456'
            }
        }

        It 'Should include is_markdown_support when switch is set' {
            $content = @{ head = @{ text = 'Test' } }
            Send-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -ToJid 'channel@conference.xmpp.zoom.us' -AccountId 'abc123' -UserJid 'user@xmpp.zoom.us' -Content $content -IsMarkdownSupport
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.is_markdown_support -eq $true
            }
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ message_id = 'msg123' } }
        }

        It 'Should accept pipeline input by property name' {
            $content = @{ head = @{ text = 'Test' } }
            [PSCustomObject]@{
                RobotJid  = 'bot@xmpp.zoom.us'
                ToJid     = 'channel@conference.xmpp.zoom.us'
                AccountId = 'abc123'
                UserJid   = 'user@xmpp.zoom.us'
                Content   = $content
            } | Send-ZoomChatbotMessage
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept pipeline input with snake_case aliases' {
            $content = @{ head = @{ text = 'Test' } }
            [PSCustomObject]@{
                robot_jid  = 'bot@xmpp.zoom.us'
                to_jid     = 'channel@conference.xmpp.zoom.us'
                account_id = 'abc123'
                user_jid   = 'user@xmpp.zoom.us'
                Content    = $content
            } | Send-ZoomChatbotMessage
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
