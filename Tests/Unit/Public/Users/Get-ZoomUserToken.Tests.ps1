BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomUserToken' {
    Context 'When retrieving user token without Type' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
                }
            }
        }

        It 'Should return user token' {
            $result = Get-ZoomUserToken -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return token property' {
            $result = Get-ZoomUserToken -UserId 'user@example.com'
            $result.token | Should -Not -BeNullOrEmpty
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/.+/token'
                $Method | Should -Be 'GET'
                return @{ token = 'test-token' }
            }

            Get-ZoomUserToken -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept email as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/user@example.com/token'
                return @{ token = 'test-token' }
            }

            Get-ZoomUserToken -UserId 'user@example.com'
        }

        It 'Should accept user ID as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/abc123xyz/token'
                return @{ token = 'test-token' }
            }

            Get-ZoomUserToken -UserId 'abc123xyz'
        }
    }

    Context 'When retrieving user token with Type parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
                }
            }
        }

        It 'Should accept Type parameter with token value' {
            { Get-ZoomUserToken -UserId 'user@example.com' -Type 'token' } | Should -Not -Throw
        }

        It 'Should accept Type parameter with zpk value' {
            { Get-ZoomUserToken -UserId 'user@example.com' -Type 'zpk' } | Should -Not -Throw
        }

        It 'Should accept Type parameter with zap value' {
            { Get-ZoomUserToken -UserId 'user@example.com' -Type 'zap' } | Should -Not -Throw
        }

        It 'Should reject invalid Type values' {
            { Get-ZoomUserToken -UserId 'user@example.com' -Type 'invalid' } | Should -Throw
        }

        It 'Should include login_type in query string when Type is provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'login_type='
                return @{ token = 'test-token' }
            }

            Get-ZoomUserToken -UserId 'user@example.com' -Type 'token'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ token = 'test-token' }
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Get-ZoomUserToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with UserId property from pipeline' {
            $userObject = [PSCustomObject]@{ UserId = 'user@example.com' }
            $result = $userObject | Get-ZoomUserToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Email property from pipeline' {
            $userObject = [PSCustomObject]@{ Email = 'user@example.com' }
            $result = $userObject | Get-ZoomUserToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Id property from pipeline' {
            $userObject = [PSCustomObject]@{ Id = 'user123' }
            $result = $userObject | Get-ZoomUserToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Type property from pipeline' {
            $userObject = [PSCustomObject]@{
                UserId = 'user@example.com'
                Type = 'token'
            }
            $result = $userObject | Get-ZoomUserToken
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ token = 'test-token' }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Get-ZoomUserToken -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Get-ZoomUserToken -EmailAddress 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Get-ZoomUserToken -Id 'user123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomUserToken -user_id 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ token = 'test-token' }
            }
        }

        It 'Should require UserId parameter' {
            { Get-ZoomUserToken } | Should -Throw
        }

        It 'Should accept UserId as positional parameter' {
            { Get-ZoomUserToken 'user@example.com' } | Should -Not -Throw
        }

        It 'Should validate Type parameter values' {
            { Get-ZoomUserToken -UserId 'user@example.com' -Type 'token' } | Should -Not -Throw
            { Get-ZoomUserToken -UserId 'user@example.com' -Type 'zpk' } | Should -Not -Throw
            { Get-ZoomUserToken -UserId 'user@example.com' -Type 'zap' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors when user not found' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomUserToken -UserId 'nonexistent@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors for unauthorized access' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Get-ZoomUserToken -UserId 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
