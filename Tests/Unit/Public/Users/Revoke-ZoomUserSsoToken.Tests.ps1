BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Revoke-ZoomUserSsoToken' {
    Context 'When revoking a user SSO token' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com/token'
                $Method | Should -Be 'DELETE'
                return @{ status = 'success' }
            }

            Revoke-ZoomUserSsoToken -UserId 'testuser@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should not include any query parameters' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.Query | Should -BeNullOrEmpty
                return @{ status = 'success' }
            }

            Revoke-ZoomUserSsoToken -UserId 'testuser@example.com'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Revoke-ZoomUserSsoToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            @('user1@example.com', 'user2@example.com') | Revoke-ZoomUserSsoToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user@example.com' }
            $userObject | Revoke-ZoomUserSsoToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with user_id property from pipeline' {
            $userObject = [PSCustomObject]@{ user_id = 'user@example.com' }
            $userObject | Revoke-ZoomUserSsoToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Return value behavior' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should return API response by default' {
            $result = Revoke-ZoomUserSsoToken -UserId 'user@example.com'
            $result.status | Should -Be 'success'
        }

        It 'Should return UserId when Passthru is specified' {
            $result = Revoke-ZoomUserSsoToken -UserId 'user@example.com' -Passthru
            $result | Should -Be 'user@example.com'
        }

        It 'Should not return API response when Passthru is specified' {
            $result = Revoke-ZoomUserSsoToken -UserId 'user@example.com' -Passthru
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [string]
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should return correct UserId for each user when processing multiple users with Passthru' {
            $results = @('user1@example.com', 'user2@example.com') | Revoke-ZoomUserSsoToken -Passthru
            $results | Should -Contain 'user1@example.com'
            $results | Should -Contain 'user2@example.com'
        }

        It 'Should return array of responses when processing multiple users without Passthru' {
            $results = @('user1@example.com', 'user2@example.com') | Revoke-ZoomUserSsoToken
            @($results).Count | Should -Be 2
            $results[0].status | Should -Be 'success'
            $results[1].status | Should -Be 'success'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Revoke-ZoomUserSsoToken -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Revoke-ZoomUserSsoToken -EmailAddress 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Revoke-ZoomUserSsoToken -Id 'user123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Revoke-ZoomUserSsoToken -user_id 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Multiple users processing' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should process each user separately' {
            Revoke-ZoomUserSsoToken -UserId @('user1@example.com', 'user2@example.com', 'user3@example.com')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should call correct endpoint for each user' {
            $callCount = 0
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $Uri.ToString() | Should -Match 'users/user1@example.com/token'
                }
                if ($script:callCount -eq 2) {
                    $Uri.ToString() | Should -Match 'users/user2@example.com/token'
                }
                return @{ status = 'success' }
            }

            Revoke-ZoomUserSsoToken -UserId @('user1@example.com', 'user2@example.com')
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Revoke-ZoomUserSsoToken -UserId 'nonexistent@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle SSO token errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('SSO token not found')
            }

            { Revoke-ZoomUserSsoToken -UserId 'user@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Revoke-ZoomUserSsoToken -UserId 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'CmdletBinding attributes' {
        It 'Should not have SupportsShouldProcess' {
            $cmd = Get-Command Revoke-ZoomUserSsoToken
            $attributes = $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $attributes.SupportsShouldProcess | Should -Not -Be $true
        }
    }
}
