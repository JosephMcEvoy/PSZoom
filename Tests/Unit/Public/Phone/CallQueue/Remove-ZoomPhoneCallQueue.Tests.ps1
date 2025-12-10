BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomPhoneCallQueue' {
    Context 'When removing a call queue' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should remove call queue successfully' {
            { Remove-ZoomPhoneCallQueue -CallQueueId 'queue123' } | Should -Not -Throw
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/call_queues/queue123'
                return @{}
            }

            Remove-ZoomPhoneCallQueue -CallQueueId 'queue123'
        }

        It 'Should use DELETE method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'Delete'
                return @{}
            }

            Remove-ZoomPhoneCallQueue -CallQueueId 'queue123'
        }
    }

    Context 'When removing multiple call queues' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept multiple CallQueueIds' {
            { Remove-ZoomPhoneCallQueue -CallQueueId 'queue123', 'queue456' } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'When using PassThru switch' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should return queue IDs with PassThru' {
            $result = Remove-ZoomPhoneCallQueue -CallQueueId 'queue123', 'queue456' -PassThru
            $result | Should -Contain 'queue123'
            $result | Should -Contain 'queue456'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            { 'queue123' | Remove-ZoomPhoneCallQueue } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $queueObject = [PSCustomObject]@{ id = 'queue123' }
            { $queueObject | Remove-ZoomPhoneCallQueue } | Should -Not -Throw
        }

        It 'Should accept multiple objects from pipeline' {
            $queues = @(
                [PSCustomObject]@{ id = 'queue123' }
                [PSCustomObject]@{ id = 'queue456' }
            )
            { $queues | Remove-ZoomPhoneCallQueue } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept Id alias for CallQueueId' {
            { Remove-ZoomPhoneCallQueue -Id 'queue123' } | Should -Not -Throw
        }

        It 'Should accept Ids alias for CallQueueId' {
            { Remove-ZoomPhoneCallQueue -Ids 'queue123', 'queue456' } | Should -Not -Throw
        }

        It 'Should accept CallQueue_Id alias for CallQueueId' {
            { Remove-ZoomPhoneCallQueue -CallQueue_Id 'queue123' } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            { Remove-ZoomPhoneCallQueue -CallQueueId 'queue123' -WhatIf } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Call queue not found')
            }

            { Remove-ZoomPhoneCallQueue -CallQueueId 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }
}
