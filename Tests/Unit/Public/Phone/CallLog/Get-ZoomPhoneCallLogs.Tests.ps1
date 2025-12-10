BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneCallLogs' {
    Context 'When retrieving all call logs' {
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

        It 'Should return call logs' {
            $result = Get-ZoomPhoneCallLogs
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple call logs' {
            $result = Get-ZoomPhoneCallLogs
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/call_logs'
                return @()
            }

            Get-ZoomPhoneCallLogs
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }
    }

    Context 'When retrieving specific call logs by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = 'log123'
                        caller = '+12345678901'
                    }
                )
            }
        }

        It 'Should accept CallLogId parameter' {
            $result = Get-ZoomPhoneCallLogs -CallLogId 'log123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be 'log123'
                return @()
            }

            Get-ZoomPhoneCallLogs -CallLogId 'log123'
        }

        It 'Should accept multiple CallLogIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneCallLogs -CallLogId 'log123', 'log456'
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

            Get-ZoomPhoneCallLogs -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneCallLogs -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneCallLogs -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = 'log123' }
                    @{ id = 'log456' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = 'log123'; details = 'full' }
                    @{ id = 'log456'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneCallLogs -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneCallLogs'
                return @()
            }

            Get-ZoomPhoneCallLogs -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept CallLogId from pipeline' {
            { 'log123' | Get-ZoomPhoneCallLogs } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $logObject = [PSCustomObject]@{ id = 'log123' }
            { $logObject | Get-ZoomPhoneCallLogs } | Should -Not -Throw
        }

        It 'Should accept object with call_log_id property from pipeline' {
            $logObject = [PSCustomObject]@{ call_log_id = 'log123' }
            { $logObject | Get-ZoomPhoneCallLogs } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for CallLogId' {
            { Get-ZoomPhoneCallLogs -id 'log123' } | Should -Not -Throw
        }

        It 'Should accept call_log_id alias for CallLogId' {
            { Get-ZoomPhoneCallLogs -call_log_id 'log123' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneCallLogs -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneCallLogs -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneCallLog alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneCallLog' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneCallLogs'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Call log not found')
            }

            { Get-ZoomPhoneCallLogs -CallLogId 'log123' -ErrorAction Stop } | Should -Throw
        }
    }
}
