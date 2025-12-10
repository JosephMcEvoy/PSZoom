BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomPhoneCallQueueMembers' {
    Context 'When removing members from call queue' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -MemberIds 'member123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/phone/call_queues/*/members*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -MemberIds 'member123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should include member_ids in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'member_ids='
                return @{ success = $true }
            }

            Remove-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -MemberIds 'member123'
        }

        It 'Should handle multiple member IDs' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'member_ids='
                return @{ success = $true }
            }

            Remove-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -MemberIds 'member123','member456'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            { 'queue123' | Remove-ZoomPhoneCallQueueMembers -MemberIds 'member123' } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $queueObject = [PSCustomObject]@{ id = 'queue123' }
            { $queueObject | Remove-ZoomPhoneCallQueueMembers -MemberIds 'member123' } | Should -Not -Throw
        }

        It 'Should accept object with CallQueue_Id property from pipeline' {
            $queueObject = [PSCustomObject]@{ CallQueue_Id = 'queue123' }
            { $queueObject | Remove-ZoomPhoneCallQueueMembers -MemberIds 'member123' } | Should -Not -Throw
        }
    }

    Context 'When using PassThru switch' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should return CallQueueId with PassThru' {
            $result = Remove-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -MemberIds 'member123' -PassThru
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
            { Remove-ZoomPhoneCallQueueMembers -id 'queue123' -MemberIds 'member123' } | Should -Not -Throw
        }

        It 'Should accept CallQueue_Id alias for CallQueueId' {
            { Remove-ZoomPhoneCallQueueMembers -CallQueue_Id 'queue123' -MemberIds 'member123' } | Should -Not -Throw
        }

        It 'Should accept member_ids alias for MemberIds' {
            { Remove-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -member_ids 'member123' } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should support WhatIf' {
            { Remove-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -MemberIds 'member123' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API error')
            }

            { Remove-ZoomPhoneCallQueueMembers -CallQueueId 'queue123' -MemberIds 'member123' -ErrorAction Stop } | Should -Throw
        }
    }
}
