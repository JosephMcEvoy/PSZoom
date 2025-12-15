BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneCallQueueMembers' {
    Context 'When retrieving call queue members' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'member123'
                        name = 'John Doe'
                        type = 'user'
                    }
                    @{
                        id = 'member456'
                        name = 'Jane Smith'
                        type = 'user'
                    }
                )
            }
        }

        It 'Should return members' {
            $result = Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple members' {
            $result = Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123'
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/call_queues/.*/members'
                return @()
            }

            Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123'
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

            Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            { 'queue123' | Get-ZoomPhoneCallQueueMembers } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $queueObject = [PSCustomObject]@{ id = 'queue123' }
            { $queueObject | Get-ZoomPhoneCallQueueMembers } | Should -Not -Throw
        }

        It 'Should accept object with CallQueue_Id property from pipeline' {
            $queueObject = [PSCustomObject]@{ CallQueue_Id = 'queue123' }
            { $queueObject | Get-ZoomPhoneCallQueueMembers } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for CallQueueId' {
            { Get-ZoomPhoneCallQueueMembers -id 'queue123' } | Should -Not -Throw
        }

        It 'Should accept CallQueue_Id alias for CallQueueId' {
            { Get-ZoomPhoneCallQueueMembers -CallQueue_Id 'queue123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Call queue not found')
            }

            { Get-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -ErrorAction Stop } | Should -Throw
        }
    }
}
