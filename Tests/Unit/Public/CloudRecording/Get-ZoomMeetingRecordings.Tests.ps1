BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    $script:MockMeetingRecordings = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/meeting-recordings.json" | ConvertFrom-Json
}

Describe 'Get-ZoomMeetingRecordings' {
    Context 'When retrieving meeting recordings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingRecordings
            }
        }

        It 'Should return recording details' {
            $result = Get-ZoomMeetingRecordings -MeetingId '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return recording with correct meeting id' {
            $result = Get-ZoomMeetingRecordings -MeetingId '1234567890'
            $result.id | Should -Be 1234567890
        }

        It 'Should return recording files' {
            $result = Get-ZoomMeetingRecordings -MeetingId '1234567890'
            $result.recording_files | Should -Not -BeNullOrEmpty
            $result.recording_files.Count | Should -BeGreaterOrEqual 1
        }

        It 'Should return share_url' {
            $result = Get-ZoomMeetingRecordings -MeetingId '1234567890'
            $result.share_url | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct recordings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*?/recordings'
                return $script:MockMeetingRecordings
            }

            Get-ZoomMeetingRecordings -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockMeetingRecordings
            }

            Get-ZoomMeetingRecordings -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingRecordings
            }
        }

        It 'Should accept MeetingId from pipeline' {
            $result = '1234567890' | Get-ZoomMeetingRecordings
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with meeting_id property from pipeline' {
            $meetingObject = [PSCustomObject]@{ meeting_id = '1234567890' }
            $result = $meetingObject | Get-ZoomMeetingRecordings
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Get-ZoomMeetingRecordings } | Should -Throw
        }

        It 'Should accept meeting_id alias for MeetingId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingRecordings
            }

            { Get-ZoomMeetingRecordings -meeting_id '1234567890' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockMeetingRecordings
            }
        }

        It 'Should accept MeetingId as first positional parameter' {
            $result = Get-ZoomMeetingRecordings '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found')
            }

            { Get-ZoomMeetingRecordings -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
