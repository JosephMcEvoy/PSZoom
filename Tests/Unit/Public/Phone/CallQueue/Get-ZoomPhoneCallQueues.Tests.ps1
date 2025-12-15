BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneCallQueues' {
    Context 'When retrieving all call queues' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'queue123'
                        name = 'Sales Queue'
                        extension_number = 1001
                        site_id = 'site123'
                    }
                    @{
                        id = 'queue456'
                        name = 'Support Queue'
                        extension_number = 1002
                        site_id = 'site123'
                    }
                )
            }
        }

        It 'Should return call queues' {
            $result = Get-ZoomPhoneCallQueues
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple call queues' {
            $result = Get-ZoomPhoneCallQueues
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/call_queues'
                return @()
            }

            Get-ZoomPhoneCallQueues
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }
    }

    Context 'When retrieving specific call queues by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'queue123'
                        name = 'Sales Queue'
                    }
                )
            }
        }

        It 'Should accept CallQueueId parameter' {
            $result = Get-ZoomPhoneCallQueues -CallQueueId 'queue123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be 'queue123'
                return @()
            }

            Get-ZoomPhoneCallQueues -CallQueueId 'queue123'
        }

        It 'Should accept multiple CallQueueIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneCallQueues -CallQueueId 'queue123', 'queue456'
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

            Get-ZoomPhoneCallQueues -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneCallQueues -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneCallQueues -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'queue123' }
                    @{ id = 'queue456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'queue123'; details = 'full' }
                    @{ id = 'queue456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneCallQueues -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneCallQueues'
                return @()
            }

            Get-ZoomPhoneCallQueues -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            { 'queue123' | Get-ZoomPhoneCallQueues } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $queueObject = [PSCustomObject]@{ id = 'queue123' }
            { $queueObject | Get-ZoomPhoneCallQueues } | Should -Not -Throw
        }

        It 'Should accept object with CallQueue_Id property from pipeline' {
            $queueObject = [PSCustomObject]@{ CallQueue_Id = 'queue123' }
            { $queueObject | Get-ZoomPhoneCallQueues } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for CallQueueId' {
            { Get-ZoomPhoneCallQueues -id 'queue123' } | Should -Not -Throw
        }

        It 'Should accept CallQueue_Id alias for CallQueueId' {
            { Get-ZoomPhoneCallQueues -CallQueue_Id 'queue123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneCallQueues -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneCallQueues -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneCallQueue alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneCallQueue' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneCallQueues'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Call queue not found')
            }

            { Get-ZoomPhoneCallQueues -CallQueueId 'queue123' -ErrorAction Stop } | Should -Throw
        }
    }
}
