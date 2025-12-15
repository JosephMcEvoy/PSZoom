BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomUserSettings' {
    Context 'When retrieving user settings without LoginType' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    scheduled_meeting = @{
                        host_video = $true
                        participant_video = $false
                        audio_type = 'both'
                    }
                    feature = @{
                        meeting_capacity = 100
                    }
                }
            }
        }

        It 'Should return user settings' {
            $result = Get-ZoomUserSettings -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return scheduled_meeting settings' {
            $result = Get-ZoomUserSettings -UserId 'user@example.com'
            $result.scheduled_meeting | Should -Not -BeNullOrEmpty
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/.+/settings'
                $Method | Should -Be 'GET'
                return @{}
            }

            Get-ZoomUserSettings -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept email as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/user@example.com/settings'
                return @{}
            }

            Get-ZoomUserSettings -UserId 'user@example.com'
        }

        It 'Should accept user ID as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/abc123xyz/settings'
                return @{}
            }

            Get-ZoomUserSettings -UserId 'abc123xyz'
        }
    }

    Context 'When retrieving user settings with LoginType' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    scheduled_meeting = @{}
                }
            }
            Mock ConvertTo-LoginTypeCode -ModuleName PSZoom {
                return '100'
            }
        }

        It 'Should accept LoginType parameter' {
            { Get-ZoomUserSettings -UserId 'user@example.com' -LoginType '100' } | Should -Not -Throw
        }

        It 'Should include login_type in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'login_type='
                return @{}
            }

            Get-ZoomUserSettings -UserId 'user@example.com' -LoginType '100'
        }

        It 'Should call ConvertTo-LoginTypeCode when LoginType is provided' {
            Get-ZoomUserSettings -UserId 'user@example.com' -LoginType '1'
            Should -Invoke ConvertTo-LoginTypeCode -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ scheduled_meeting = @{} }
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Get-ZoomUserSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with UserId property from pipeline' {
            $userObject = [PSCustomObject]@{ UserId = 'user@example.com' }
            $result = $userObject | Get-ZoomUserSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Email property from pipeline' {
            $userObject = [PSCustomObject]@{ Email = 'user@example.com' }
            $result = $userObject | Get-ZoomUserSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with Id property from pipeline' {
            $userObject = [PSCustomObject]@{ Id = 'user123' }
            $result = $userObject | Get-ZoomUserSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with LoginType property from pipeline' {
            Mock ConvertTo-LoginTypeCode -ModuleName PSZoom {
                return '100'
            }
            $userObject = [PSCustomObject]@{
                UserId = 'user@example.com'
                LoginType = '100'
            }
            $result = $userObject | Get-ZoomUserSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ scheduled_meeting = @{} }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Get-ZoomUserSettings -Email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Get-ZoomUserSettings -EmailAddress 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Get-ZoomUserSettings -Id 'user123' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomUserSettings -user_id 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept login_type alias for LoginType' {
            Mock ConvertTo-LoginTypeCode -ModuleName PSZoom {
                return '100'
            }
            { Get-ZoomUserSettings -UserId 'user@example.com' -login_type '100' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ scheduled_meeting = @{} }
            }
        }

        It 'Should require UserId parameter' {
            { Get-ZoomUserSettings } | Should -Throw
        }

        It 'Should accept UserId as positional parameter' {
            { Get-ZoomUserSettings 'user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors when user not found' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomUserSettings -UserId 'nonexistent@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors for unauthorized access' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Unauthorized')
            }

            { Get-ZoomUserSettings -UserId 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
