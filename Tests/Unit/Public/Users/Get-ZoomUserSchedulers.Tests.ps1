BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomUserSchedulers' {
    Context 'When retrieving user schedulers' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    schedulers = @(
                        @{
                            id = 'scheduler1'
                            email = 'scheduler1@example.com'
                        },
                        @{
                            id = 'scheduler2'
                            email = 'scheduler2@example.com'
                        }
                    )
                }
            }
        }

        It 'Should return schedulers list' {
            $result = Get-ZoomUserSchedulers -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return schedulers array' {
            $result = Get-ZoomUserSchedulers -UserId 'user@example.com'
            $result.schedulers | Should -Not -BeNullOrEmpty
            $result.schedulers.Count | Should -Be 2
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/.+/schedulers'
                $Method | Should -Be 'GET'
                return @{ schedulers = @() }
            }

            Get-ZoomUserSchedulers -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept email as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/user@example.com/schedulers'
                return @{ schedulers = @() }
            }

            Get-ZoomUserSchedulers -UserId 'user@example.com'
        }

        It 'Should accept user ID as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/abc123xyz/schedulers'
                return @{ schedulers = @() }
            }

            Get-ZoomUserSchedulers -UserId 'abc123xyz'
        }
    }

    Context 'When user has no schedulers' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    schedulers = @()
                }
            }
        }

        It 'Should return empty schedulers array' {
            $result = Get-ZoomUserSchedulers -UserId 'user@example.com'
            $result.schedulers | Should -BeNullOrEmpty
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ schedulers = @() }
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Get-ZoomUserSchedulers
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with UserId property from pipeline' {
            $userObject = [PSCustomObject]@{ UserId = 'user@example.com' }
            $result = $userObject | Get-ZoomUserSchedulers
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Email property from pipeline' {
            $userObject = [PSCustomObject]@{ Email = 'user@example.com' }
            $result = $userObject | Get-ZoomUserSchedulers
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Id property from pipeline' {
            $userObject = [PSCustomObject]@{ Id = 'user123' }
            $result = $userObject | Get-ZoomUserSchedulers
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ schedulers = @() }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Get-ZoomUserSchedulers -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Get-ZoomUserSchedulers -EmailAddress 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Get-ZoomUserSchedulers -Id 'user123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomUserSchedulers -user_id 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ schedulers = @() }
            }
        }

        It 'Should require UserId parameter' {
            { Get-ZoomUserSchedulers } | Should -Throw
        }

        It 'Should accept UserId as positional parameter' {
            { Get-ZoomUserSchedulers 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors when user not found' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomUserSchedulers -UserId 'nonexistent@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors for unauthorized access' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Get-ZoomUserSchedulers -UserId 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
