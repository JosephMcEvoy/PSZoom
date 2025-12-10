BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomPhoneCallQueueNumber' {
    Context 'When removing phone number from call queue' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -NumberId 'number123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/phone/call_queues/*/phone_numbers/*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -NumberId 'number123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should accept phone number as NumberId' {
            { Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -NumberId '+12345678901' } | Should -Not -Throw
        }

        It 'Should accept ID string as NumberId' {
            { Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -NumberId 'abc123def456' } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            { 'queue123' | Remove-ZoomPhoneCallQueueNumber -NumberId 'number123' } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $queueObject = [PSCustomObject]@{ id = 'queue123' }
            { $queueObject | Remove-ZoomPhoneCallQueueNumber -NumberId 'number123' } | Should -Not -Throw
        }

        It 'Should accept object with CallQueue_Id property from pipeline' {
            $queueObject = [PSCustomObject]@{ CallQueue_Id = 'queue123' }
            { $queueObject | Remove-ZoomPhoneCallQueueNumber -NumberId 'number123' } | Should -Not -Throw
        }
    }

    Context 'When using PassThru switch' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should return CallQueueId with PassThru' {
            $result = Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -NumberId 'number123' -PassThru
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
            { Remove-ZoomPhoneCallQueueNumber -id 'queue123' -NumberId 'number123' } | Should -Not -Throw
        }

        It 'Should accept CallQueue_Id alias for CallQueueId' {
            { Remove-ZoomPhoneCallQueueNumber -CallQueue_Id 'queue123' -NumberId 'number123' } | Should -Not -Throw
        }

        It 'Should accept number_id alias for NumberId' {
            { Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -number_id 'number123' } | Should -Not -Throw
        }

        It 'Should accept Phone_Number_Id alias for NumberId' {
            { Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Phone_Number_Id 'number123' } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should support WhatIf' {
            { Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -NumberId 'number123' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API error')
            }

            { Remove-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -NumberId 'number123' -ErrorAction Stop } | Should -Throw
        }
    }
}
