BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneUserRecordings' {
    Context 'When retrieving user recordings' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'rec123'
                        caller = '+12345678901'
                        duration = 120
                        file_size = 1024000
                    }
                    @{
                        id = 'rec456'
                        caller = '+15551234567'
                        duration = 300
                        file_size = 2048000
                    }
                )
            }
        }

        It 'Should return recordings for a user' {
            $result = Get-ZoomPhoneUserRecordings -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple recordings' {
            $result = Get-ZoomPhoneUserRecordings -UserId 'user123'
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI with user ID' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/users/user123/recordings'
                return @()
            }

            Get-ZoomPhoneUserRecordings -UserId 'user123'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }

        It 'Should accept email address as UserId' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'user@example.com'
                return @()
            }

            Get-ZoomPhoneUserRecordings -UserId 'user@example.com'
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

            Get-ZoomPhoneUserRecordings -UserId 'user123' -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneUserRecordings -UserId 'user123' -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneUserRecordings -UserId 'user123' -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When processing multiple users' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'rec123' }
                )
            }
        }

        It 'Should process multiple user IDs' {
            $result = Get-ZoomPhoneUserRecordings -UserId 'user1', 'user2'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 2
        }

        It 'Should call API for each user' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                return @(@{ id = 'rec1' })
            }

            $result = Get-ZoomPhoneUserRecordings -UserId 'user1', 'user2', 'user3'
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
            { 'user123' | Get-ZoomPhoneUserRecordings } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user123' }
            { $userObject | Get-ZoomPhoneUserRecordings } | Should -Not -Throw
        }

        It 'Should accept object with email property from pipeline' {
            $userObject = [PSCustomObject]@{ email = 'user@example.com' }
            { $userObject | Get-ZoomPhoneUserRecordings } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept email alias for UserId' {
            { Get-ZoomPhoneUserRecordings -email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomPhoneUserRecordings -user_id 'user123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneUserRecordings -UserId 'user123' -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneUserRecordings -UserId 'user123' -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomPhoneUserRecordings -UserId 'invalid-user' -ErrorAction Stop } | Should -Throw
        }
    }
}
