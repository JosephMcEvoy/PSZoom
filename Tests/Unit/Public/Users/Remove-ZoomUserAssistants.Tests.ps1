BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomUserAssistants' {
    Context 'When removing all user assistants' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com/assistants'
                $Method | Should -Be 'DELETE'
                return $null
            }

            Remove-ZoomUserAssistants -UserId 'testuser@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should not include any query parameters' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.Query | Should -BeNullOrEmpty
                return $null
            }

            Remove-ZoomUserAssistants -UserId 'testuser@example.com'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Remove-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            @('user1@example.com', 'user2@example.com') | Remove-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user@example.com' }
            $userObject | Remove-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with user_id property from pipeline' {
            $userObject = [PSCustomObject]@{ user_id = 'user@example.com' }
            $userObject | Remove-ZoomUserAssistants
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should return UserId array when Passthru is specified' {
            $result = Remove-ZoomUserAssistants -UserId 'user@example.com' -Passthru
            $result | Should -Contain 'user@example.com'
        }

        It 'Should not return output when Passthru is not specified' {
            $result = Remove-ZoomUserAssistants -UserId 'user@example.com'
            $result | Should -BeNullOrEmpty
        }

        It 'Should return correct UserId for each user when processing multiple users with Passthru' {
            $results = @('user1@example.com', 'user2@example.com') | Remove-ZoomUserAssistants -Passthru
            $results | Should -Contain 'user1@example.com'
            $results | Should -Contain 'user2@example.com'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept Email alias for UserId' {
            { Remove-ZoomUserAssistants -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Remove-ZoomUserAssistants -EmailAddress 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Remove-ZoomUserAssistants -Id 'user123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Remove-ZoomUserAssistants -user_id 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Multiple users processing' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should process each user separately' {
            Remove-ZoomUserAssistants -UserId @('user1@example.com', 'user2@example.com', 'user3@example.com')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should call correct endpoint for each user' {
            $callCount = 0
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $Uri.ToString() | Should -Match 'users/user1@example.com/assistants'
                }
                if ($script:callCount -eq 2) {
                    $Uri.ToString() | Should -Match 'users/user2@example.com/assistants'
                }
                return $null
            }

            Remove-ZoomUserAssistants -UserId @('user1@example.com', 'user2@example.com')
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Remove-ZoomUserAssistants -UserId 'nonexistent@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Remove-ZoomUserAssistants -UserId 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'CmdletBinding attributes' {
        It 'Should not have SupportsShouldProcess' {
            $cmd = Get-Command Remove-ZoomUserAssistants
            $attributes = $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $attributes.SupportsShouldProcess | Should -Not -Be $true
        }
    }
}
