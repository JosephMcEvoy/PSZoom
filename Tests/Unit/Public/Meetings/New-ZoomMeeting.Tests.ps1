BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomMeeting' {
    Context 'When creating an instant meeting' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = '1234567890'
                    topic = 'Test Meeting'
                    type = 1
                    start_url = 'https://zoom.us/start/123'
                    join_url = 'https://zoom.us/j/123'
                }
            }
        }

        It 'Should create meeting with required parameters' {
            $result = New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test Meeting'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return meeting with id' {
            $result = New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test Meeting'
            $result.id | Should -Be '1234567890'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct meetings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/users/.*/meetings'
                return @{ id = '123' }
            }

            New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'Post'
                return @{ id = '123' }
            }

            New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Scheduled meeting parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = '123'; type = 2 }
            }
        }

        It 'Should accept scheduled meeting parameters' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -StartTime '2024-01-15T10:00:00Z' -Duration 60 } | Should -Not -Throw
        }

        It 'Should accept Timezone parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -StartTime '2024-01-15T10:00:00Z' -Duration 60 -Timezone 'America/New_York' } | Should -Not -Throw
        }
    }

    Context 'Optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = '123' }
            }
        }

        It 'Should accept Password parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -Password 'test123' } | Should -Not -Throw
        }

        It 'Should accept Agenda parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -Agenda 'Test agenda' } | Should -Not -Throw
        }

        It 'Should accept ScheduleFor parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -ScheduleFor 'other@example.com' } | Should -Not -Throw
        }
    }

    Context 'Meeting settings parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = '123' }
            }
        }

        It 'Should accept HostVideo parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -HostVideo $true } | Should -Not -Throw
        }

        It 'Should accept JoinBeforeHost parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -JoinBeforeHost $true } | Should -Not -Throw
        }

        It 'Should accept WaitingRoom parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -WaitingRoom $true } | Should -Not -Throw
        }

        It 'Should accept MuteUponEntry parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' -Topic 'Test' -MuteUponEntry $true } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require UserId parameter' {
            { New-ZoomMeeting -Topic 'Test' } | Should -Throw
        }

        It 'Should require Topic parameter' {
            { New-ZoomMeeting -UserId 'user@example.com' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { New-ZoomMeeting -UserId 'nonexistent' -Topic 'Test' -ErrorAction Stop } | Should -Throw
        }
    }
}
