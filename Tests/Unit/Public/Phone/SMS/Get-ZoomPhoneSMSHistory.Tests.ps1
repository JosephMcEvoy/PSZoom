BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneSMSHistory' {
    Context 'When retrieving SMS history' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'sms123'
                        message = 'Hello'
                        type = 'outbound'
                        date_time = '2024-01-01T12:00:00Z'
                    }
                    @{
                        id = 'sms456'
                        message = 'Hi there'
                        type = 'inbound'
                        date_time = '2024-01-01T13:00:00Z'
                    }
                )
            }
        }

        It 'Should return SMS history' {
            $result = Get-ZoomPhoneSMSHistory -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple SMS messages' {
            $result = Get-ZoomPhoneSMSHistory -UserId 'user@example.com'
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/sms/history'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com'
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }

        It 'Should include user_id in query parameters' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['user_id'] | Should -Be 'user@example.com'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com'
        }
    }

    Context 'When using date range filters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should include from date in query parameters' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['from'] | Should -Be '2024-01-01'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -From '2024-01-01'
        }

        It 'Should include to date in query parameters' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['to'] | Should -Be '2024-01-31'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -To '2024-01-31'
        }

        It 'Should include both from and to dates' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['from'] | Should -Be '2024-01-01'
                $AdditionalQueryStatements['to'] | Should -Be '2024-01-31'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -From '2024-01-01' -To '2024-01-31'
        }
    }

    Context 'When filtering by message type' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should filter by inbound messages' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['message_type'] | Should -Be 'inbound'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -MessageType 'inbound'
        }

        It 'Should filter by outbound messages' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['message_type'] | Should -Be 'outbound'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -MessageType 'outbound'
        }

        It 'Should use all as default message type' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['message_type'] | Should -Be 'all'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com'
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

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept UserId from pipeline' {
            { 'user@example.com' | Get-ZoomPhoneSMSHistory } | Should -Not -Throw
        }

        It 'Should accept object with user_id property from pipeline' {
            $userObject = [PSCustomObject]@{ user_id = 'user@example.com' }
            { $userObject | Get-ZoomPhoneSMSHistory } | Should -Not -Throw
        }

        It 'Should accept object with email property from pipeline' {
            $userObject = [PSCustomObject]@{ email = 'user@example.com' }
            { $userObject | Get-ZoomPhoneSMSHistory } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept user_id alias for UserId' {
            { Get-ZoomPhoneSMSHistory -user_id 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept email alias for UserId' {
            { Get-ZoomPhoneSMSHistory -email 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept message_type alias for MessageType' {
            { Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -message_type 'inbound' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should require UserId parameter' {
            { Get-ZoomPhoneSMSHistory -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('SMS history not found')
            }

            { Get-ZoomPhoneSMSHistory -UserId 'user@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
