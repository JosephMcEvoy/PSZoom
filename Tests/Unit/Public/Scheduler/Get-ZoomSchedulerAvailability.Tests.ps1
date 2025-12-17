BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomSchedulerAvailability' {
    Context 'When retrieving a scheduler availability' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'avail123'
                    name = 'Work Hours'
                    schedule = @{
                        timezone = 'America/New_York'
                    }
                }
            }
        }

        It 'Should return availability details' {
            $result = Get-ZoomSchedulerAvailability -AvailabilityId 'avail123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return availability with correct id' {
            $result = Get-ZoomSchedulerAvailability -AvailabilityId 'avail123'
            $result.id | Should -Be 'avail123'
        }

        It 'Should return availability with name' {
            $result = Get-ZoomSchedulerAvailability -AvailabilityId 'avail123'
            $result.name | Should -Be 'Work Hours'
        }

        It 'Should return availability with schedule' {
            $result = Get-ZoomSchedulerAvailability -AvailabilityId 'avail123'
            $result.schedule | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct availability endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/scheduler/availability/avail123'
                return @{}
            }

            Get-ZoomSchedulerAvailability -AvailabilityId 'avail123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{}
            }

            Get-ZoomSchedulerAvailability -AvailabilityId 'avail123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'avail123'
                    name = 'Work Hours'
                }
            }
        }

        It 'Should accept AvailabilityId from pipeline' {
            $result = 'avail123' | Get-ZoomSchedulerAvailability
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with availability_id property from pipeline' {
            $availabilityObject = [PSCustomObject]@{ availability_id = 'avail123' }
            $result = $availabilityObject | Get-ZoomSchedulerAvailability
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with id property from pipeline' {
            $availabilityObject = [PSCustomObject]@{ id = 'avail123' }
            $result = $availabilityObject | Get-ZoomSchedulerAvailability
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept availability_id alias for AvailabilityId' {
            { Get-ZoomSchedulerAvailability -availability_id 'avail123' } | Should -Not -Throw
        }

        It 'Should accept id alias for AvailabilityId' {
            { Get-ZoomSchedulerAvailability -id 'avail123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept AvailabilityId as first positional parameter' {
            $result = Get-ZoomSchedulerAvailability 'avail123'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Availability not found')
            }

            { Get-ZoomSchedulerAvailability -AvailabilityId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
