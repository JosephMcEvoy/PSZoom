BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomSchedulerAvailability' {
    Context 'When creating a scheduler availability' {
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

        It 'Should return created availability' {
            $schedule = @{ timezone = 'America/New_York' }
            $result = New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return availability with correct name' {
            $schedule = @{ timezone = 'America/New_York' }
            $result = New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule
            $result.name | Should -Be 'Work Hours'
        }

        It 'Should return availability with id' {
            $schedule = @{ timezone = 'America/New_York' }
            $result = New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule
            $result.id | Should -Be 'avail123'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct availability endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/scheduler/availability$'
                return @{}
            }

            $schedule = @{ timezone = 'America/New_York' }
            New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{}
            }

            $schedule = @{ timezone = 'America/New_York' }
            New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Name in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.name | Should -Be 'Work Hours'
                return @{}
            }

            $schedule = @{ timezone = 'America/New_York' }
            New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Schedule in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule | Should -Not -BeNullOrEmpty
                $bodyObj.schedule.timezone | Should -Be 'America/New_York'
                return @{}
            }

            $schedule = @{ timezone = 'America/New_York' }
            New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'avail123' }
            }
        }

        It 'Should accept object with name and schedule properties from pipeline' {
            $availabilityObject = [PSCustomObject]@{
                name = 'Work Hours'
                schedule = @{ timezone = 'America/New_York' }
            }
            $result = $availabilityObject | New-ZoomSchedulerAvailability
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept name alias for Name' {
            $schedule = @{ timezone = 'America/New_York' }
            { New-ZoomSchedulerAvailability -name 'Work Hours' -Schedule $schedule } | Should -Not -Throw
        }

        It 'Should accept schedule alias for Schedule' {
            { New-ZoomSchedulerAvailability -Name 'Work Hours' -schedule @{ timezone = 'America/New_York' } } | Should -Not -Throw
        }
    }

    Context 'Complex schedule objects' {
        It 'Should handle complex schedule with days and intervals' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.schedule.days | Should -Not -BeNullOrEmpty
                return @{}
            }

            $schedule = @{
                timezone = 'America/New_York'
                days = @(
                    @{ day = 'Monday'; intervals = @(@{ from = '09:00'; to = '17:00' }) }
                )
            }
            New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Failed to create availability')
            }

            $schedule = @{ timezone = 'America/New_York' }
            { New-ZoomSchedulerAvailability -Name 'Work Hours' -Schedule $schedule -ErrorAction Stop } | Should -Throw
        }
    }
}
