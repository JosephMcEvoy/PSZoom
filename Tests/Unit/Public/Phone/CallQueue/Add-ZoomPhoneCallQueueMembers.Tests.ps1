BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomPhoneCallQueueMembers' {
    Context 'When adding members to call queue' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            $members = @(@{ id = 'user123'; type = 'user' })
            Add-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -Members $members
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/phone/call_queues/*/members'
            }
        }

        It 'Should use POST method' {
            $members = @(@{ id = 'user123'; type = 'user' })
            Add-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -Members $members
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should include members in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.members | Should -Not -BeNullOrEmpty
                $bodyObj.members.Count | Should -Be 2
                return @{ success = $true }
            }

            $members = @(
                @{ id = 'user123'; type = 'user' }
                @{ id = 'user456'; type = 'user' }
            )
            Add-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -Members $members
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            $members = @(@{ id = 'user123'; type = 'user' })
            { 'queue123' | Add-ZoomPhoneCallQueueMembers -Members $members } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $queueObject = [PSCustomObject]@{ id = 'queue123' }
            $members = @(@{ id = 'user123'; type = 'user' })
            { $queueObject | Add-ZoomPhoneCallQueueMembers -Members $members } | Should -Not -Throw
        }

        It 'Should accept object with CallQueue_Id property from pipeline' {
            $queueObject = [PSCustomObject]@{ CallQueue_Id = 'queue123' }
            $members = @(@{ id = 'user123'; type = 'user' })
            { $queueObject | Add-ZoomPhoneCallQueueMembers -Members $members } | Should -Not -Throw
        }
    }

    Context 'When using PassThru switch' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should return CallQueueId with PassThru' {
            $members = @(@{ id = 'user123'; type = 'user' })
            $result = Add-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -Members $members -PassThru
            $result | Should -Be 'queue123'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept id alias for CallQueueId' {
            $members = @(@{ id = 'user123'; type = 'user' })
            { Add-ZoomPhoneCallQueueMembers -id 'queue123' -Members $members } | Should -Not -Throw
        }

        It 'Should accept CallQueue_Id alias for CallQueueId' {
            $members = @(@{ id = 'user123'; type = 'user' })
            { Add-ZoomPhoneCallQueueMembers -CallQueue_Id 'queue123' -Members $members } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should support WhatIf' {
            $members = @(@{ id = 'user123'; type = 'user' })
            { Add-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -Members $members -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API error')
            }

            $members = @(@{ id = 'user123'; type = 'user' })
            { Add-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -Members $members -ErrorAction Stop } | Should -Throw
        }
    }
}
