BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneUserVoicemails' {
    Context 'When retrieving user voicemails' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'vm123'
                        caller = '+12345678901'
                        duration = 60
                        status = 'unread'
                    }
                    @{
                        id = 'vm456'
                        caller = '+15551234567'
                        duration = 90
                        status = 'read'
                    }
                )
            }
        }

        It 'Should return voicemails for a user' {
            $result = Get-ZoomPhoneUserVoicemails -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple voicemails' {
            $result = Get-ZoomPhoneUserVoicemails -UserId 'user123'
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI with user ID' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/users/user123/voicemails'
                return @()
            }

            Get-ZoomPhoneUserVoicemails -UserId 'user123'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }

        It 'Should accept email address as UserId' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'user@example.com'
                return @()
            }

            Get-ZoomPhoneUserVoicemails -UserId 'user@example.com'
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

            Get-ZoomPhoneUserVoicemails -UserId 'user123' -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneUserVoicemails -UserId 'user123' -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneUserVoicemails -UserId 'user123' -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When processing multiple users' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'vm123' }
                )
            }
        }

        It 'Should process multiple user IDs' {
            $result = Get-ZoomPhoneUserVoicemails -UserId 'user1', 'user2'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 2
        }

        It 'Should call API for each user' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                return @(@{ id = 'vm1' })
            }

            $result = Get-ZoomPhoneUserVoicemails -UserId 'user1', 'user2', 'user3'
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
            { 'user123' | Get-ZoomPhoneUserVoicemails } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user123' }
            { $userObject | Get-ZoomPhoneUserVoicemails } | Should -Not -Throw
        }

        It 'Should accept object with email property from pipeline' {
            $userObject = [PSCustomObject]@{ email = 'user@example.com' }
            { $userObject | Get-ZoomPhoneUserVoicemails } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept email alias for UserId' {
            { Get-ZoomPhoneUserVoicemails -email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomPhoneUserVoicemails -user_id 'user123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneUserVoicemails -UserId 'user123' -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneUserVoicemails -UserId 'user123' -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomPhoneUserVoicemails -UserId 'invalid-user' -ErrorAction Stop } | Should -Throw
        }
    }
}
