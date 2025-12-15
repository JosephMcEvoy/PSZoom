BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomPhoneCallQueue' {
    Context 'When creating a call queue with required parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'queue123'
                    name = 'Sales Queue'
                    site_id = 'site123'
                }
            }
        }

        It 'Should create call queue successfully' {
            $result = New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should use correct URI' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri | Should -Match 'https://api.zoom.us/v2/phone/call_queues'
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123'
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123'
        }

        It 'Should include name and site_id in body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'Sales Queue'
                $bodyObj.site_id | Should -Be 'site123'
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123'
        }
    }

    Context 'When creating a call queue with optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'queue123' }
            }
        }

        It 'Should accept Description parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.description | Should -Be 'Customer Support Queue'
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Support Queue' -SiteId 'site123' -Description 'Customer Support Queue'
        }

        It 'Should accept ExtensionNumber parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.extension_number | Should -Be 1001
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123' -ExtensionNumber 1001
        }

        It 'Should accept Timezone parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.timezone | Should -Be 'America/New_York'
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123' -Timezone 'America/New_York'
        }

        It 'Should accept MaxWaitTime parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.max_wait_time | Should -Be 300
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123' -MaxWaitTime 300
        }

        It 'Should accept MaxQueueSize parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.max_queue_size | Should -Be 50
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123' -MaxQueueSize 50
        }

        It 'Should accept WrapUpTime parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.wrap_up_time | Should -Be 60
                return @{ id = 'queue123' }
            }

            New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123' -WrapUpTime 60
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'queue123' }
            }
        }

        It 'Should require Name parameter' {
            { New-ZoomPhoneCallQueue -SiteId 'site123' -ErrorAction Stop } | Should -Throw
        }

        It 'Should require SiteId parameter' {
            { New-ZoomPhoneCallQueue -Name 'Sales Queue' -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate MaxWaitTime range (minimum)' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -MaxWaitTime 5 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate MaxWaitTime range (maximum)' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -MaxWaitTime 1000 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate MaxQueueSize range (minimum)' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -MaxQueueSize 0 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate MaxQueueSize range (maximum)' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -MaxQueueSize 101 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate WrapUpTime range (minimum)' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -WrapUpTime -1 -ErrorAction Stop } | Should -Throw
        }

        It 'Should validate WrapUpTime range (maximum)' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -WrapUpTime 301 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When using PassThru switch' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'queue123' }
            }
        }

        It 'Should return queue ID with PassThru' {
            $result = New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123' -PassThru
            $result | Should -Be 'queue123'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'queue123' }
            }
        }

        It 'Should accept site_id alias for SiteId' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -site_id 'site123' } | Should -Not -Throw
        }

        It 'Should accept extension_number alias for ExtensionNumber' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -extension_number 1001 } | Should -Not -Throw
        }

        It 'Should accept max_wait_time alias for MaxWaitTime' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -max_wait_time 300 } | Should -Not -Throw
        }

        It 'Should accept max_queue_size alias for MaxQueueSize' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -max_queue_size 50 } | Should -Not -Throw
        }

        It 'Should accept wrap_up_time alias for WrapUpTime' {
            { New-ZoomPhoneCallQueue -Name 'Queue' -SiteId 'site123' -wrap_up_time 60 } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'queue123' }
            }
        }

        It 'Should support WhatIf' {
            { New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123' -WhatIf } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API error occurred')
            }

            { New-ZoomPhoneCallQueue -Name 'Sales Queue' -SiteId 'site123' -ErrorAction Stop } | Should -Throw
        }
    }
}
