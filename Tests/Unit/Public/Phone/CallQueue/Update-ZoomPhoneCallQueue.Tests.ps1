BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomPhoneCallQueue' {
    Context 'When updating a call queue' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should update call queue successfully' {
            { Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Name 'Updated Queue' } | Should -Not -Throw
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/call_queues/queue123'
                return @{}
            }

            Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Name 'Updated Queue'
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Name 'Updated Queue'
        }

        It 'Should include only provided parameters in body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'Updated Queue'
                $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'description'
                return @{}
            }

            Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Name 'Updated Queue'
        }
    }

    Context 'When updating with optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept Name parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'New Name'
                return @{}
            }

            Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Name 'New Name'
        }

        It 'Should accept Description parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.description | Should -Be 'New Description'
                return @{}
            }

            Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Description 'New Description'
        }

        It 'Should accept ExtensionNumber parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.extension_number | Should -Be 2001
                return @{}
            }

            Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -ExtensionNumber 2001
        }

        It 'Should accept multiple parameters' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'New Name'
                $bodyObj.max_wait_time | Should -Be 300
                $bodyObj.max_queue_size | Should -Be 50
                return @{}
            }

            Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Name 'New Name' -MaxWaitTime 300 -MaxQueueSize 50
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should require CallQueueId parameter' {
            { Update-ZoomPhoneCallQueue -Name 'Queue' -ErrorAction Stop } | Should -Throw
        }

        It 'Should require at least one update parameter' {
            { Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate MaxWaitTime range (minimum)' {
            { Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -MaxWaitTime 5 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate MaxWaitTime range (maximum)' {
            { Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -MaxWaitTime 1000 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate MaxQueueSize range (minimum)' {
            { Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -MaxQueueSize 0 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate MaxQueueSize range (maximum)' {
            { Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -MaxQueueSize 101 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When using PassThru switch' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should return queue ID with PassThru' {
            $result = Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Name 'Updated' -PassThru
            $result | Should -Be 'queue123'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            { 'queue123' | Update-ZoomPhoneCallQueue -Name 'Updated' } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept id alias for CallQueueId' {
            { Update-ZoomPhoneCallQueue -id 'queue123' -Name 'Queue' } | Should -Not -Throw
        }

        It 'Should accept extension_number alias for ExtensionNumber' {
            { Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -extension_number 2001 } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API error occurred')
            }

            { Update-ZoomPhoneCallQueue -CallQueueId 'queue123' -Name 'Updated' -ErrorAction Stop } | Should -Throw
        }
    }
}
