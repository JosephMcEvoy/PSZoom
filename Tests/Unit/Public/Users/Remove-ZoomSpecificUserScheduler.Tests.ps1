BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomSpecificUserScheduler' {
    Context 'When removing a specific scheduler' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com/schedulers/scheduler@example.com'
                $Method | Should -Be 'DELETE'
                return $null
            }

            Remove-ZoomSpecificUserScheduler -UserId 'testuser@example.com' -SchedulerId 'scheduler@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept UserId from pipeline' {
            'user1@example.com' | Remove-ZoomSpecificUserScheduler -SchedulerId 'scheduler@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds' {
            @('user1@example.com', 'user2@example.com') | Remove-ZoomSpecificUserScheduler -SchedulerId 'scheduler@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should process multiple SchedulerIds' {
            Remove-ZoomSpecificUserScheduler -UserId 'user@example.com' -SchedulerId @('scheduler1@example.com', 'scheduler2@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should process multiple UserIds and SchedulerIds' {
            Remove-ZoomSpecificUserScheduler -UserId @('user1@example.com', 'user2@example.com') -SchedulerId @('scheduler1@example.com', 'scheduler2@example.com') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 4
        }
    }

    Context 'SupportsShouldProcess behavior' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should support WhatIf parameter' {
            Remove-ZoomSpecificUserScheduler -UserId 'user@example.com' -SchedulerId 'scheduler@example.com' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm parameter' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }

            Remove-ZoomSpecificUserScheduler -UserId 'user@example.com' -SchedulerId 'scheduler@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should return UserId array when Passthru is specified' {
            $result = Remove-ZoomSpecificUserScheduler -UserId 'user@example.com' -SchedulerId 'scheduler@example.com' -Passthru -Confirm:$false
            $result | Should -Contain 'user@example.com'
        }

        It 'Should not return output when Passthru is not specified' {
            $result = Remove-ZoomSpecificUserScheduler -UserId 'user@example.com' -SchedulerId 'scheduler@example.com' -Confirm:$false
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept Email alias for UserId' {
            { Remove-ZoomSpecificUserScheduler -Email 'user@example.com' -SchedulerId 'scheduler@example.com' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Remove-ZoomSpecificUserScheduler -EmailAddress 'user@example.com' -SchedulerId 'scheduler@example.com' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Remove-ZoomSpecificUserScheduler -Id 'user123' -SchedulerId 'scheduler@example.com' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Remove-ZoomSpecificUserScheduler -user_id 'user@example.com' -SchedulerId 'scheduler@example.com' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept scheduler_id alias for SchedulerId' {
            { Remove-ZoomSpecificUserScheduler -UserId 'user@example.com' -scheduler_id 'scheduler@example.com' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Scheduler not found')
            }

            { Remove-ZoomSpecificUserScheduler -UserId 'user@example.com' -SchedulerId 'nonexistent@example.com' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
