BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomMeeting' {
    Context 'When updating a meeting' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Update-ZoomMeeting -MeetingId '1234567890' -Topic 'Updated Topic' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct meeting endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/'
                return @{}
            }

            Update-ZoomMeeting -MeetingId '1234567890' -Topic 'Updated Topic'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomMeeting -MeetingId '1234567890' -Topic 'Updated Topic'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Meeting parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept Topic parameter' {
            { Update-ZoomMeeting -MeetingId '1234567890' -Topic 'New Topic' } | Should -Not -Throw
        }

        It 'Should accept Duration parameter' {
            { Update-ZoomMeeting -MeetingId '1234567890' -Duration 90 } | Should -Not -Throw
        }

        It 'Should accept StartTime parameter' {
            { Update-ZoomMeeting -MeetingId '1234567890' -StartTime '2024-01-20T14:00:00Z' } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept MeetingId from pipeline' {
            { '1234567890' | Update-ZoomMeeting -Topic 'Updated' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Update-ZoomMeeting -Topic 'Test' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Update-ZoomMeeting -MeetingId 'nonexistent' -Topic 'Test' -ErrorAction Stop } | Should -Throw
        }
    }
}
