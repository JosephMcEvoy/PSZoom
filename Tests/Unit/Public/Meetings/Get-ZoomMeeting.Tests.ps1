BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Set up required module state
    $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
    $script:ZoomURI = 'zoom.us'

    # Load mock response fixtures
    $script:MockMeetingGet = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/meeting-get.json" | ConvertFrom-Json
}

Describe 'Get-ZoomMeeting' {
    Context 'When retrieving a meeting by MeetingId' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingGet
            }
        }

        It 'Should return meeting details' {
            $result = Get-ZoomMeeting -MeetingId '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return meeting with correct id' {
            $result = Get-ZoomMeeting -MeetingId '1234567890'
            $result.id | Should -Be 1234567890
        }

        It 'Should return meeting with correct topic' {
            $result = Get-ZoomMeeting -MeetingId '1234567890'
            $result.topic | Should -Be 'Weekly Team Standup'
        }

        It 'Should return meeting with host information' {
            $result = Get-ZoomMeeting -MeetingId '1234567890'
            $result.host_id | Should -Not -BeNullOrEmpty
            $result.host_email | Should -Be 'jane.doe@example.com'
        }

        It 'Should return meeting settings' {
            $result = Get-ZoomMeeting -MeetingId '1234567890'
            $result.settings | Should -Not -BeNullOrEmpty
            $result.settings.waiting_room | Should -BeTrue
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct meeting endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/9876543210'
                return $script:MockMeetingGet
            }

            Get-ZoomMeeting -MeetingId '9876543210'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockMeetingGet
            }

            Get-ZoomMeeting -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'OccurrenceId parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingGet
            }
        }

        It 'Should accept OccurrenceId parameter' {
            { Get-ZoomMeeting -MeetingId '1234567890' -OccurrenceId 'occurrence123' } | Should -Not -Throw
        }

        It 'Should include occurrence_id in query string when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'occurrence_id=occurrence123'
                return $script:MockMeetingGet
            }

            Get-ZoomMeeting -MeetingId '1234567890' -OccurrenceId 'occurrence123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingGet
            }
        }

        It 'Should accept MeetingId from pipeline' {
            $result = '1234567890' | Get-ZoomMeeting
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with meeting_id property from pipeline' {
            $meetingObject = [PSCustomObject]@{ meeting_id = '1234567890' }
            $result = $meetingObject | Get-ZoomMeeting
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should process multiple meetings from pipeline' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingGet
            }

            @('meeting1', 'meeting2', 'meeting3') | ForEach-Object { Get-ZoomMeeting -MeetingId $_ }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Get-ZoomMeeting } | Should -Throw
        }

        It 'Should accept meeting_id alias for MeetingId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingGet
            }

            { Get-ZoomMeeting -meeting_id '1234567890' } | Should -Not -Throw
        }

        It 'Should accept ocurrence_id alias for OccurrenceId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingGet
            }

            { Get-ZoomMeeting -MeetingId '123' -ocurrence_id 'occ123' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingGet
            }
        }

        It 'Should accept MeetingId as first positional parameter' {
            $result = Get-ZoomMeeting '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept OccurrenceId as second positional parameter' {
            { Get-ZoomMeeting '1234567890' 'occurrence123' } | Should -Not -Throw
        }
    }

    Context 'Integration with Get-ZoomUser' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                if ($Uri -match '/meetings/') {
                    return $script:MockMeetingGet
                } else {
                    return @{ id = 'KDcuGIm1QgePTO8WbOqwIQ'; email = 'jane.doe@example.com' }
                }
            }
        }

        It 'Should allow piping host_id to Get-ZoomUser' {
            $meeting = Get-ZoomMeeting -MeetingId '1234567890'
            $meeting.host_id | Should -Be 'KDcuGIm1QgePTO8WbOqwIQ'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors for invalid meeting' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Get-ZoomMeeting -MeetingId 'invalid' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle 404 for non-existent meeting' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('The remote server returned an error: (404) Not Found.')
            }

            { Get-ZoomMeeting -MeetingId 'nonexistent123' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Return value structure' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingGet
            }
        }

        It 'Should return object with expected properties' {
            $result = Get-ZoomMeeting -MeetingId '1234567890'

            $result.uuid | Should -Not -BeNullOrEmpty
            $result.id | Should -Not -BeNullOrEmpty
            $result.host_id | Should -Not -BeNullOrEmpty
            $result.topic | Should -Not -BeNullOrEmpty
            $result.type | Should -Not -BeNullOrEmpty
            $result.start_time | Should -Not -BeNullOrEmpty
            $result.duration | Should -Not -BeNullOrEmpty
            $result.timezone | Should -Not -BeNullOrEmpty
            $result.join_url | Should -Not -BeNullOrEmpty
        }

        It 'Should return meeting type as integer' {
            $result = Get-ZoomMeeting -MeetingId '1234567890'
            $result.type | Should -BeOfType [int]
        }

        It 'Should return duration as integer' {
            $result = Get-ZoomMeeting -MeetingId '1234567890'
            $result.duration | Should -BeOfType [int]
        }
    }
}
