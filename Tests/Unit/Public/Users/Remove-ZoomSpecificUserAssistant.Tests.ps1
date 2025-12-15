BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomSpecificUserAssistant' {
    Context 'When removing a specific assistant' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    success = $true
                }
            }
        }

        It 'Should remove assistant' {
            $result = Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' -AssistantId 'assistant123'
            $result | Should -Not -BeNull
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/.+/assistants/.+'
                $Method | Should -Be 'DELETE'
                return @{}
            }

            Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' -AssistantId 'assistant123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include both UserId and AssistantId in endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/user@example.com/assistants/assistant123'
                return @{}
            }

            Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' -AssistantId 'assistant123'
        }

        It 'Should accept user ID as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/abc123xyz/assistants'
                return @{}
            }

            Remove-ZoomSpecificUserAssistant -UserId 'abc123xyz' -AssistantId 'assistant123'
        }
    }

    Context 'When removing multiple assistants from single user' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should process multiple AssistantIds' {
            Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' -AssistantId @('assistant1', 'assistant2', 'assistant3')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should call API once per AssistantId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                return @{}
            }

            Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' -AssistantId @('assistant1', 'assistant2')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'When removing assistants from multiple users' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should process multiple UserIds' {
            Remove-ZoomSpecificUserAssistant -UserId @('user1@example.com', 'user2@example.com') -AssistantId 'assistant123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should process multiple UserIds and AssistantIds' {
            Remove-ZoomSpecificUserAssistant -UserId @('user1@example.com', 'user2@example.com') -AssistantId @('assistant1', 'assistant2')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 4
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Remove-ZoomSpecificUserAssistant -AssistantId 'assistant123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            $results = @('user1@example.com', 'user2@example.com') | Remove-ZoomSpecificUserAssistant -AssistantId 'assistant123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with UserId property from pipeline' {
            $userObject = [PSCustomObject]@{
                UserId = 'user@example.com'
                AssistantId = 'assistant123'
            }
            $result = $userObject | Remove-ZoomSpecificUserAssistant
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Email property from pipeline' {
            $userObject = [PSCustomObject]@{
                Email = 'user@example.com'
                AssistantId = 'assistant123'
            }
            $result = $userObject | Remove-ZoomSpecificUserAssistant
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Id property from pipeline' {
            $userObject = [PSCustomObject]@{
                Id = 'user123'
                AssistantId = 'assistant123'
            }
            $result = $userObject | Remove-ZoomSpecificUserAssistant
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept Email alias for UserId' {
            { Remove-ZoomSpecificUserAssistant -Email 'user@example.com' -AssistantId 'assistant123' } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Remove-ZoomSpecificUserAssistant -EmailAddress 'user@example.com' -AssistantId 'assistant123' } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Remove-ZoomSpecificUserAssistant -Id 'user123' -AssistantId 'assistant123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Remove-ZoomSpecificUserAssistant -user_id 'user@example.com' -AssistantId 'assistant123' } | Should -Not -Throw
        }

        It 'Should accept assistant_id alias for AssistantId' {
            { Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' -assistant_id 'assistant123' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should require UserId parameter' {
            { Remove-ZoomSpecificUserAssistant -AssistantId 'assistant123' } | Should -Throw
        }

        It 'Should require AssistantId parameter' {
            { Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' } | Should -Throw
        }

        It 'Should accept UserId as positional parameter at position 0' {
            { Remove-ZoomSpecificUserAssistant 'user@example.com' 'assistant123' } | Should -Not -Throw
        }

        It 'Should accept AssistantId as positional parameter at position 1' {
            { Remove-ZoomSpecificUserAssistant 'user@example.com' 'assistant123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors when user not found' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Remove-ZoomSpecificUserAssistant -UserId 'nonexistent@example.com' -AssistantId 'assistant123' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors when assistant not found' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Assistant not found')
            }

            { Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' -AssistantId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors for unauthorized access' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Remove-ZoomSpecificUserAssistant -UserId 'user@example.com' -AssistantId 'assistant123' -ErrorAction Stop } | Should -Throw
        }
    }
}
