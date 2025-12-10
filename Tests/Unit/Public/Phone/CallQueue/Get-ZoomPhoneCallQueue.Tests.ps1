BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneCallQueue' {
    Context 'When retrieving a specific call queue' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'queue123'
                    name = 'Sales Queue'
                    extension_number = 1001
                    site_id = 'site123'
                }
            }
        }

        It 'Should return call queue details' {
            $result = Get-ZoomPhoneCallQueue -CallQueueId 'queue123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/call_queues/queue123'
                return @{ id = 'queue123' }
            }

            Get-ZoomPhoneCallQueue -CallQueueId 'queue123'
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ id = 'queue123' }
            }

            Get-ZoomPhoneCallQueue -CallQueueId 'queue123'
        }
    }

    Context 'When retrieving multiple call queues' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                if ($Uri -match 'queue123') {
                    return @{ id = 'queue123'; name = 'Queue 1' }
                }
                if ($Uri -match 'queue456') {
                    return @{ id = 'queue456'; name = 'Queue 2' }
                }
            }
        }

        It 'Should accept multiple CallQueueIds' {
            $result = Get-ZoomPhoneCallQueue -CallQueueId 'queue123', 'queue456'
            $result.Count | Should -Be 2
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'queue123' }
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            { 'queue123' | Get-ZoomPhoneCallQueue } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $queueObject = [PSCustomObject]@{ id = 'queue123' }
            { $queueObject | Get-ZoomPhoneCallQueue } | Should -Not -Throw
        }

        It 'Should accept object with CallQueue_Id property from pipeline' {
            $queueObject = [PSCustomObject]@{ CallQueue_Id = 'queue123' }
            { $queueObject | Get-ZoomPhoneCallQueue } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'queue123' }
            }
        }

        It 'Should accept id alias for CallQueueId' {
            { Get-ZoomPhoneCallQueue -id 'queue123' } | Should -Not -Throw
        }

        It 'Should accept CallQueue_Id alias for CallQueueId' {
            { Get-ZoomPhoneCallQueue -CallQueue_Id 'queue123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Call queue not found')
            }

            { Get-ZoomPhoneCallQueue -CallQueueId 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }
}
