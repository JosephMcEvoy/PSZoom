BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomMeetingInvitation' {
    Context 'When retrieving meeting invitation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ invitation = 'Meeting invitation text...' }
            }
        }

        It 'Should return invitation' {
            $result = Get-ZoomMeetingInvitation -MeetingId '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return invitation text' {
            $result = Get-ZoomMeetingInvitation -MeetingId '1234567890'
            $result.invitation | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct invitation endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/invitation'
                return @{ invitation = 'test' }
            }

            Get-ZoomMeetingInvitation -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ invitation = 'test' }
            }
        }

        It 'Should accept MeetingId from pipeline' {
            $result = '1234567890' | Get-ZoomMeetingInvitation
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Get-ZoomMeetingInvitation } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Get-ZoomMeetingInvitation -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
