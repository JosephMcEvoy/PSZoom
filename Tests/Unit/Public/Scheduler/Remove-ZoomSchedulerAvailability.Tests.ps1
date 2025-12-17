BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomSchedulerAvailability' {
    Context 'When removing a scheduler availability' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/scheduler/availability/avail123*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should return true on success' {
            $result = Remove-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Confirm:$false
            $result | Should -Be $true
        }

        It 'Should support ShouldProcess with WhatIf' {
            Remove-ZoomSchedulerAvailability -AvailabilityId 'avail123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept AvailabilityId from pipeline' {
            'avail123' | Remove-ZoomSchedulerAvailability -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with availability_id property from pipeline' {
            [PSCustomObject]@{ availability_id = 'avail123' } | Remove-ZoomSchedulerAvailability -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id property from pipeline' {
            [PSCustomObject]@{ id = 'avail123' } | Remove-ZoomSchedulerAvailability -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept availability_id alias for AvailabilityId' {
            { Remove-ZoomSchedulerAvailability -availability_id 'avail123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias for AvailabilityId' {
            { Remove-ZoomSchedulerAvailability -id 'avail123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept AvailabilityId as first positional parameter' {
            $result = Remove-ZoomSchedulerAvailability 'avail123' -Confirm:$false
            $result | Should -Be $true
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should have ConfirmImpact set to High' {
            $command = Get-Command Remove-ZoomSchedulerAvailability
            $cmdletBinding = $command.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }

        It 'Should not call API when WhatIf is specified' {
            Remove-ZoomSchedulerAvailability -AvailabilityId 'avail123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should call API when Confirm is false' {
            Remove-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Failed to delete availability')
            }

            { Remove-ZoomSchedulerAvailability -AvailabilityId 'nonexistent' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
