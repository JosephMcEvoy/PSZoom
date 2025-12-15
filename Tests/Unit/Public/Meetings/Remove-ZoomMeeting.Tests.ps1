BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomMeeting' {
    Context 'When removing a meeting' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Remove-ZoomMeeting -MeetingId '1234567890' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct meeting endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/'
                return @{}
            }

            Remove-ZoomMeeting -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use DELETE method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'DELETE'
                return @{}
            }

            Remove-ZoomMeeting -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'OccurrenceId parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept OccurrenceId parameter' {
            { Remove-ZoomMeeting -MeetingId '1234567890' -OccurrenceId 'occ123' } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept MeetingId from pipeline' {
            { '1234567890' | Remove-ZoomMeeting } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Remove-ZoomMeeting } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Remove-ZoomMeeting -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
