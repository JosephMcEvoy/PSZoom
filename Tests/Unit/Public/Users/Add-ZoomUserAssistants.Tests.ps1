BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomUserAssistants' {
    Context 'When adding assistants by email' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    add_at = '2023-01-15T10:00:00Z'
                    ids = @('assistant1', 'assistant2')
                }
            }
        }

        It 'Should add assistant to user' {
            $result = Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantEmail 'assistant@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $Uri.ToString() | Should -Match 'users/.+/assistants'
                $Method | Should -Be 'POST'
                return @{}
            }

            Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantEmail 'assistant@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include assistants in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.assistants | Should -Not -BeNullOrEmpty
                $bodyObj.assistants[0].email | Should -Be 'assistant@example.com'
                return @{}
            }

            Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantEmail 'assistant@example.com'
        }

        It 'Should add multiple assistants by email' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.assistants.Count | Should -Be 2
                return @{}
            }

            Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantEmail @('assistant1@example.com', 'assistant2@example.com')
        }
    }

    Context 'When adding assistants by ID' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    add_at = '2023-01-15T10:00:00Z'
                    ids = @('assistant123')
                }
            }
        }

        It 'Should add assistant by ID' {
            $result = Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantId 'assistant123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should include assistant ID in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.assistants[0].id | Should -Be 'assistant123'
                return @{}
            }

            Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantId 'assistant123'
        }

        It 'Should add multiple assistants by ID' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.assistants.Count | Should -Be 2
                return @{}
            }

            Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantId @('assistant1', 'assistant2')
        }
    }

    Context 'When adding assistants with mixed email and ID' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept both email and ID parameters' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.assistants.Count | Should -Be 2
                return @{}
            }

            Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantEmail 'assistant@example.com' -AssistantId 'assistant123'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Add-ZoomUserAssistants -AssistantEmail 'assistant@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            $results = @('user1@example.com', 'user2@example.com') | Add-ZoomUserAssistants -AssistantEmail 'assistant@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with UserId property from pipeline' {
            $userObject = [PSCustomObject]@{
                UserId = 'user@example.com'
                AssistantEmail = 'assistant@example.com'
            }
            $result = $userObject | Add-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ result = 'success' }
            }
        }

        It 'Should return UserId when Passthru is used' {
            $result = Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantEmail 'assistant@example.com' -Passthru
            $result | Should -Be 'user@example.com'
        }

        It 'Should return API response when Passthru is not used' {
            $result = Add-ZoomUserAssistants -UserId 'user@example.com' -AssistantEmail 'assistant@example.com'
            $result.result | Should -Be 'success'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept Email alias for UserId' {
            { Add-ZoomUserAssistants -Email 'user@example.com' -AssistantEmail 'assistant@example.com' } | Should -Not -Throw
        }

        It 'Should accept ID alias for UserId' {
            { Add-ZoomUserAssistants -ID 'user123' -AssistantEmail 'assistant@example.com' } | Should -Not -Throw
        }

        It 'Should accept assistantemails alias' {
            { Add-ZoomUserAssistants -UserId 'user@example.com' -assistantemails 'assistant@example.com' } | Should -Not -Throw
        }

        It 'Should accept assistantids alias' {
            { Add-ZoomUserAssistants -UserId 'user@example.com' -assistantids 'assistant123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Add-ZoomUserAssistants -UserId 'nonexistent@example.com' -AssistantEmail 'assistant@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
