BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomPhoneCallQueueNumber' {
    Context 'When adding phone number to call queue' {
        BeforeEach {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return @{
                    id = 'number123'
                    number = '+12345678901'
                }
            }

            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/phone/call_queues/*/phone_numbers'
            }
        }

        It 'Should use POST method' {
            Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should include phone_numbers in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.phone_numbers | Should -Not -BeNullOrEmpty
                return @{ success = $true }
            }

            Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901'
        }

        It 'Should validate phone number exists' {
            { Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901' } | Should -Not -Throw
            Should -Invoke Get-ZoomPhoneNumber -ModuleName PSZoom -Times 1
        }

        It 'Should add plus sign if missing from number' {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return @{
                    id = 'number123'
                    number = '+12345678901'
                }
            }

            { Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '12345678901' } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return @{
                    id = 'number123'
                    number = '+12345678901'
                }
            }

            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept CallQueueId from pipeline' {
            { 'queue123' | Add-ZoomPhoneCallQueueNumber -Number '+12345678901' } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $queueObject = [PSCustomObject]@{ id = 'queue123' }
            { $queueObject | Add-ZoomPhoneCallQueueNumber -Number '+12345678901' } | Should -Not -Throw
        }

        It 'Should accept object with CallQueue_Id property from pipeline' {
            $queueObject = [PSCustomObject]@{ CallQueue_Id = 'queue123' }
            { $queueObject | Add-ZoomPhoneCallQueueNumber -Number '+12345678901' } | Should -Not -Throw
        }
    }

    Context 'When using PassThru switch' {
        BeforeEach {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return @{
                    id = 'number123'
                    number = '+12345678901'
                }
            }

            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should return CallQueueId with PassThru' {
            $result = Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901' -PassThru
            $result | Should -Be 'queue123'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return @{
                    id = 'number123'
                    number = '+12345678901'
                }
            }

            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should accept id alias for CallQueueId' {
            { Add-ZoomPhoneCallQueueNumber -id 'queue123' -Number '+12345678901' } | Should -Not -Throw
        }

        It 'Should accept CallQueue_Id alias for CallQueueId' {
            { Add-ZoomPhoneCallQueueNumber -CallQueue_Id 'queue123' -Number '+12345678901' } | Should -Not -Throw
        }

        It 'Should accept Phone_Number alias for Number' {
            { Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Phone_Number '+12345678901' } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return @{
                    id = 'number123'
                    number = '+12345678901'
                }
            }

            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ success = $true }
            }
        }

        It 'Should support WhatIf' {
            { Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901' -WhatIf } | Should -Not -Throw
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Error handling' {
        It 'Should throw error if number not found' {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return $null
            }

            { Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901' -ErrorAction Stop } | Should -Throw
        }

        It 'Should throw error if number already assigned' {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return @{
                    id = 'number123'
                    number = '+12345678901'
                    assignee = @{ id = 'user123' }
                }
            }

            { Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901' -ErrorAction Stop } | Should -Throw
        }

        It 'Should propagate API errors' {
            Mock Get-ZoomPhoneNumber -ModuleName PSZoom {
                return @{
                    id = 'number123'
                    number = '+12345678901'
                }
            }

            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API error')
            }

            { Add-ZoomPhoneCallQueueNumber -CallQueueId 'queue123' -Number '+12345678901' -ErrorAction Stop } | Should -Throw
        }
    }
}
