BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneUserCallLogs' {
    Context 'When retrieving user call logs' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'log123'
                        caller = '+12345678901'
                        callee = '+19876543210'
                        duration = 120
                    }
                    @{
                        id = 'log456'
                        caller = '+15551234567'
                        callee = '+15559876543'
                        duration = 300
                    }
                )
            }
        }

        It 'Should return call logs for a user' {
            $result = Get-ZoomPhoneUserCallLogs -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple call logs' {
            $result = Get-ZoomPhoneUserCallLogs -UserId 'user123'
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI with user ID' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/users/user123/call_logs'
                return @()
            }

            Get-ZoomPhoneUserCallLogs -UserId 'user123'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }

        It 'Should accept email address as UserId' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'user@example.com'
                return @()
            }

            Get-ZoomPhoneUserCallLogs -UserId 'user@example.com'
        }
    }

    Context 'When using pagination parameters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept PageSize parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($PageSize)
                $PageSize | Should -Be 50
                return @()
            }

            Get-ZoomPhoneUserCallLogs -UserId 'user123' -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneUserCallLogs -UserId 'user123' -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneUserCallLogs -UserId 'user123' -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When processing multiple users' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'log123' }
                )
            }
        }

        It 'Should process multiple user IDs' {
            $result = Get-ZoomPhoneUserCallLogs -UserId 'user1', 'user2'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 2
        }

        It 'Should call API for each user' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                return @(@{ id = 'log1' })
            }

            $result = Get-ZoomPhoneUserCallLogs -UserId 'user1', 'user2', 'user3'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 3
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept UserId from pipeline' {
            { 'user123' | Get-ZoomPhoneUserCallLogs } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user123' }
            { $userObject | Get-ZoomPhoneUserCallLogs } | Should -Not -Throw
        }

        It 'Should accept object with email property from pipeline' {
            $userObject = [PSCustomObject]@{ email = 'user@example.com' }
            { $userObject | Get-ZoomPhoneUserCallLogs } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept email alias for UserId' {
            { Get-ZoomPhoneUserCallLogs -email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomPhoneUserCallLogs -user_id 'user123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneUserCallLogs -UserId 'user123' -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneUserCallLogs -UserId 'user123' -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomPhoneUserCallLogs -UserId 'invalid-user' -ErrorAction Stop } | Should -Throw
        }
    }
}
