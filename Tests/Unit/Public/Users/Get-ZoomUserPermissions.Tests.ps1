BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomUserPermissions' {
    Context 'When retrieving user permissions' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    permissions = @(
                        'User:Read:Admin',
                        'User:Write:Admin',
                        'Meeting:Read:Admin'
                    )
                }
            }
        }

        It 'Should return permissions list' {
            $result = Get-ZoomUserPermissions -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return permissions array' {
            $result = Get-ZoomUserPermissions -UserId 'user@example.com'
            $result.permissions | Should -Not -BeNullOrEmpty
            $result.permissions.Count | Should -Be 3
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/.+/permissions'
                $Method | Should -Be 'GET'
                return @{ permissions = @() }
            }

            Get-ZoomUserPermissions -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept email as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/user@example.com/permissions'
                return @{ permissions = @() }
            }

            Get-ZoomUserPermissions -UserId 'user@example.com'
        }

        It 'Should accept user ID as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/abc123xyz/permissions'
                return @{ permissions = @() }
            }

            Get-ZoomUserPermissions -UserId 'abc123xyz'
        }
    }

    Context 'When user has no special permissions' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    permissions = @()
                }
            }
        }

        It 'Should return empty permissions array' {
            $result = Get-ZoomUserPermissions -UserId 'basicuser@example.com'
            $result.permissions | Should -BeNullOrEmpty
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ permissions = @('User:Read:Admin') }
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Get-ZoomUserPermissions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with UserId property from pipeline' {
            $userObject = [PSCustomObject]@{ UserId = 'user@example.com' }
            $result = $userObject | Get-ZoomUserPermissions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Email property from pipeline' {
            $userObject = [PSCustomObject]@{ Email = 'user@example.com' }
            $result = $userObject | Get-ZoomUserPermissions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Id property from pipeline' {
            $userObject = [PSCustomObject]@{ Id = 'user123' }
            $result = $userObject | Get-ZoomUserPermissions
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ permissions = @() }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Get-ZoomUserPermissions -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Get-ZoomUserPermissions -EmailAddress 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Get-ZoomUserPermissions -Id 'user123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomUserPermissions -user_id 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ permissions = @() }
            }
        }

        It 'Should require UserId parameter' {
            { Get-ZoomUserPermissions } | Should -Throw
        }

        It 'Should accept UserId as positional parameter' {
            { Get-ZoomUserPermissions 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors when user not found' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomUserPermissions -UserId 'nonexistent@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors for unauthorized access' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Get-ZoomUserPermissions -UserId 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
