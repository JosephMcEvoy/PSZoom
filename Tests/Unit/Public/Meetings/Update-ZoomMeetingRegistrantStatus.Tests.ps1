BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomMeetingRegistrantStatus' {
    Context 'When updating registrant status' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Update-ZoomMeetingRegistrantStatus -MeetingId '1234567890' -Action 'approve' -Registrants @(@{ id = 'reg123' }) } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct registrants status endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/registrants/status'
                return @{}
            }

            Update-ZoomMeetingRegistrantStatus -MeetingId '1234567890' -Action 'approve' -Registrants @(@{ id = 'reg123' })
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PUT method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PUT'
                return @{}
            }

            Update-ZoomMeetingRegistrantStatus -MeetingId '1234567890' -Action 'approve' -Registrants @(@{ id = 'reg123' })
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Action parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept approve action' {
            { Update-ZoomMeetingRegistrantStatus -MeetingId '1234567890' -Action 'approve' -Registrants @(@{ id = 'reg123' }) } | Should -Not -Throw
        }

        It 'Should accept deny action' {
            { Update-ZoomMeetingRegistrantStatus -MeetingId '1234567890' -Action 'deny' -Registrants @(@{ id = 'reg123' }) } | Should -Not -Throw
        }

        It 'Should accept cancel action' {
            { Update-ZoomMeetingRegistrantStatus -MeetingId '1234567890' -Action 'cancel' -Registrants @(@{ id = 'reg123' }) } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Update-ZoomMeetingRegistrantStatus -Action 'approve' -Registrants @(@{ id = 'reg123' }) } | Should -Throw
        }

        It 'Should require Action parameter' {
            { Update-ZoomMeetingRegistrantStatus -MeetingId '1234567890' -Registrants @(@{ id = 'reg123' }) } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Update-ZoomMeetingRegistrantStatus -MeetingId 'nonexistent' -Action 'approve' -Registrants @(@{ id = 'reg123' }) -ErrorAction Stop } | Should -Throw
        }
    }
}
