BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomSchedulerAvailability' {
    Context 'When updating a scheduler availability' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'avail123'
                    name = 'Updated Work Hours'
                    schedule = @{
                        timezone = 'America/Los_Angeles'
                    }
                }
            }
        }

        It 'Should return updated availability' {
            $result = Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Name 'Updated Work Hours'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return availability with updated name' {
            $result = Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Name 'Updated Work Hours'
            $result.name | Should -Be 'Updated Work Hours'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct availability endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/scheduler/availability/avail123'
                return @{}
            }

            Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Name 'Updated Work Hours'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Name 'Updated Work Hours'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Name in request body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'Updated Work Hours'
                return @{}
            }

            Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Name 'Updated Work Hours'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Schedule in request body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule | Should -Not -BeNullOrEmpty
                $bodyObj.schedule.timezone | Should -Be 'America/Los_Angeles'
                return @{}
            }

            $schedule = @{ timezone = 'America/Los_Angeles' }
            Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should not include Name in request body when not provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'name'
                return @{}
            }

            $schedule = @{ timezone = 'America/Los_Angeles' }
            Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Optional parameters' {
        It 'Should allow updating only Name' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'Updated Work Hours'
                $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'schedule'
                return @{}
            }

            Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Name 'Updated Work Hours'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should allow updating only Schedule' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule | Should -Not -BeNullOrEmpty
                $bodyObj.PSObject.Properties.Name | Should -Not -Contain 'name'
                return @{}
            }

            $schedule = @{ timezone = 'America/Los_Angeles' }
            Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should allow updating both Name and Schedule' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'Updated Work Hours'
                $bodyObj.schedule | Should -Not -BeNullOrEmpty
                return @{}
            }

            $schedule = @{ timezone = 'America/Los_Angeles' }
            Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -Name 'Updated Work Hours' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'avail123' }
            }
        }

        It 'Should accept AvailabilityId from pipeline' {
            $result = 'avail123' | Update-ZoomSchedulerAvailability -Name 'Updated Work Hours'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with availability_id property from pipeline' {
            $availabilityObject = [PSCustomObject]@{
                availability_id = 'avail123'
                name = 'Updated Work Hours'
            }
            $result = $availabilityObject | Update-ZoomSchedulerAvailability
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with id property from pipeline' {
            $availabilityObject = [PSCustomObject]@{
                id = 'avail123'
                name = 'Updated Work Hours'
            }
            $result = $availabilityObject | Update-ZoomSchedulerAvailability
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
            { Update-ZoomSchedulerAvailability -availability_id 'avail123' -Name 'Updated Work Hours' } | Should -Not -Throw
        }

        It 'Should accept id alias for AvailabilityId' {
            { Update-ZoomSchedulerAvailability -id 'avail123' -Name 'Updated Work Hours' } | Should -Not -Throw
        }

        It 'Should accept availability_name alias for Name' {
            { Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -availability_name 'Updated Work Hours' } | Should -Not -Throw
        }

        It 'Should accept schedule_config alias for Schedule' {
            $schedule = @{ timezone = 'America/Los_Angeles' }
            { Update-ZoomSchedulerAvailability -AvailabilityId 'avail123' -schedule_config $schedule } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept AvailabilityId as first positional parameter' {
            $result = Update-ZoomSchedulerAvailability 'avail123' -Name 'Updated Work Hours'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Failed to update availability')
            }

            { Update-ZoomSchedulerAvailability -AvailabilityId 'nonexistent' -Name 'Updated' -ErrorAction Stop } | Should -Throw
        }
    }
}
