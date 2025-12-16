BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomChatbotMessage' {
    Context 'When deleting a chatbot message' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    message_id = 'msg123'
                    robot_jid  = 'bot@xmpp.zoom.us'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI including message ID' {
            Remove-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/im/chat/messages/msg123*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should include required parameters in query string' {
            Remove-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*robot_jid=bot%40xmpp.zoom.us*' -and
                $Uri -like '*account_id=abc123*'
            }
        }

        It 'Should return response' {
            $result = Remove-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Confirm:$false
            $result.message_id | Should -Be 'msg123'
        }
    }

    Context 'When using optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ message_id = 'msg123' } }
        }

        It 'Should include user_jid in query string when specified' {
            Remove-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -UserJid 'user@xmpp.zoom.us' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*user_jid=user%40xmpp.zoom.us*'
            }
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ message_id = 'msg123' } }
        }

        It 'Should not call API when -WhatIf is specified' {
            Remove-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should call API when -Confirm:$false is specified' {
            Remove-ZoomChatbotMessage -MessageId 'msg123' -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ message_id = 'msg123' } }
        }

        It 'Should accept MessageId from pipeline' {
            'msg123' | Remove-ZoomChatbotMessage -RobotJid 'bot@xmpp.zoom.us' -AccountId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*msg123*'
            }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{
                MessageId = 'msg123'
                RobotJid  = 'bot@xmpp.zoom.us'
                AccountId = 'abc123'
            } | Remove-ZoomChatbotMessage -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept message_id alias from pipeline' {
            [PSCustomObject]@{
                message_id = 'msg123'
                robot_jid  = 'bot@xmpp.zoom.us'
                account_id = 'abc123'
            } | Remove-ZoomChatbotMessage -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
