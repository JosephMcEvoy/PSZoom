BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPastMeetingDetails' {
    Context 'When retrieving past meeting details' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ uuid = 'abc123'; id = 1234567890; topic = 'Past Meeting' }
            }
        }

        It 'Should return meeting details' {
            $result = Get-ZoomPastMeetingDetails -MeetingUuid 'abc123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return meeting with uuid' {
            $result = Get-ZoomPastMeetingDetails -MeetingUuid 'abc123'
            $result.uuid | Should -Be 'abc123'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct past_meetings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/past_meetings/'
                return @{ uuid = 'abc123' }
            }

            Get-ZoomPastMeetingDetails -MeetingUuid 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ uuid = 'abc123' }
            }
        }

        It 'Should accept MeetingUuid from pipeline' {
            $result = 'abc123' | Get-ZoomPastMeetingDetails
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingUuid parameter' {
            { Get-ZoomPastMeetingDetails } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Get-ZoomPastMeetingDetails -MeetingUuid 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
