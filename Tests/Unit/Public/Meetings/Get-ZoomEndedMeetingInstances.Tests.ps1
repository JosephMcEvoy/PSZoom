BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomEndedMeetingInstances' {
    Context 'When retrieving ended meeting instances' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ meetings = @(@{ uuid = 'abc123'; start_time = '2024-01-15T10:00:00Z' }) }
            }
        }

        It 'Should return meeting instances' {
            $result = Get-ZoomEndedMeetingInstances -MeetingId '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return meetings array' {
            $result = Get-ZoomEndedMeetingInstances -MeetingId '1234567890'
            $result.meetings | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct past_meetings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/past_meetings/'
                return @{ meetings = @() }
            }

            Get-ZoomEndedMeetingInstances -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ meetings = @() }
            }
        }

        It 'Should accept MeetingId from pipeline' {
            $result = '1234567890' | Get-ZoomEndedMeetingInstances
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Get-ZoomEndedMeetingInstances } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Get-ZoomEndedMeetingInstances -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
