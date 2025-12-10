BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomUserAssistants' {
    Context 'When retrieving user assistants' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    assistants = @(
                        @{
                            id = 'assistant1'
                            email = 'assistant1@example.com'
                        },
                        @{
                            id = 'assistant2'
                            email = 'assistant2@example.com'
                        }
                    )
                }
            }
        }

        It 'Should return assistants list' {
            $result = Get-ZoomUserAssistants -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return assistants array' {
            $result = Get-ZoomUserAssistants -UserId 'user@example.com'
            $result.assistants | Should -Not -BeNullOrEmpty
            $result.assistants.Count | Should -Be 2
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/.+/assistants'
                $Method | Should -Be 'GET'
                return @{ assistants = @() }
            }

            Get-ZoomUserAssistants -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept email as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/user@example.com/assistants'
                return @{ assistants = @() }
            }

            Get-ZoomUserAssistants -UserId 'user@example.com'
        }

        It 'Should accept user ID as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/abc123xyz/assistants'
                return @{ assistants = @() }
            }

            Get-ZoomUserAssistants -UserId 'abc123xyz'
        }
    }

    Context 'When user has no assistants' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    assistants = @()
                }
            }
        }

        It 'Should return empty assistants array' {
            $result = Get-ZoomUserAssistants -UserId 'user@example.com'
            $result.assistants | Should -BeNullOrEmpty
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ assistants = @() }
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Get-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            $results = @('user1@example.com', 'user2@example.com', 'user3@example.com') | Get-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should accept object with UserId property from pipeline' {
            $userObject = [PSCustomObject]@{ UserId = 'user@example.com' }
            $result = $userObject | Get-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Email property from pipeline' {
            $userObject = [PSCustomObject]@{ Email = 'user@example.com' }
            $result = $userObject | Get-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Id property from pipeline' {
            $userObject = [PSCustomObject]@{ Id = 'user123' }
            $result = $userObject | Get-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ assistants = @() }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Get-ZoomUserAssistants -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Get-ZoomUserAssistants -EmailAddress 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Get-ZoomUserAssistants -Id 'user123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomUserAssistants -user_id 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept userids alias for UserId' {
            { Get-ZoomUserAssistants -userids 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept ids alias for UserId' {
            { Get-ZoomUserAssistants -ids 'user123' } | Should -Not -Throw
        }

        It 'Should accept emailaddresses alias for UserId' {
            { Get-ZoomUserAssistants -emailaddresses 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept emails alias for UserId' {
            { Get-ZoomUserAssistants -emails 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ assistants = @() }
            }
        }

        It 'Should require UserId parameter' {
            { Get-ZoomUserAssistants } | Should -Throw
        }

        It 'Should accept UserId as positional parameter' {
            { Get-ZoomUserAssistants 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomUserAssistants -UserId 'nonexistent@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
