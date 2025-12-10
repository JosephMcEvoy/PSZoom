BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPastMeetingParticipantsMetrics' {
    Context 'When retrieving participant metrics' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 1
                    page_size = 300
                    total_records = 2
                    participants = @(
                        @{ id = 'part1'; user_name = 'User 1'; join_time = '2024-01-15T10:00:00Z' }
                        @{ id = 'part2'; user_name = 'User 2'; join_time = '2024-01-15T10:05:00Z' }
                    )
                }
            }
        }

        It 'Should return participant metrics' {
            $result = Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return participants array' {
            $result = Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123'
            $result.participants | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct metrics endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/metrics/meetings/.*/participants'
                return @{ participants = @() }
            }

            Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ participants = @() }
            }

            Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ participants = @() }
            }
        }

        It 'Should accept MeetingUuid from pipeline' {
            $result = 'abc123' | Get-ZoomPastMeetingParticipantsMetrics
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Type parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ participants = @() }
            }
        }

        It 'Should accept past type' {
            { Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123' -Type 'past' } | Should -Not -Throw
        }

        It 'Should accept pastOne type' {
            { Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123' -Type 'pastOne' } | Should -Not -Throw
        }

        It 'Should accept live type' {
            { Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123' -Type 'live' } | Should -Not -Throw
        }
    }

    Context 'Pagination parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ participants = @() }
            }
        }

        It 'Should accept PageSize parameter' {
            { Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123' -PageSize 100 } | Should -Not -Throw
        }

        It 'Should accept NextPageToken parameter' {
            { Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'abc123' -NextPageToken 'token123' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingUuid parameter' {
            { Get-ZoomPastMeetingParticipantsMetrics } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Get-ZoomPastMeetingParticipantsMetrics -MeetingUuid 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
