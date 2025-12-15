BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomMeetingRegistrants' {
    Context 'When listing meeting registrants' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ registrants = @(@{ id = 'reg123'; email = 'user@example.com' }) }
            }
        }

        It 'Should return registrants' {
            $result = Get-ZoomMeetingRegistrants -MeetingId '1234567890'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return registrants array' {
            $result = Get-ZoomMeetingRegistrants -MeetingId '1234567890'
            $result.registrants | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct registrants endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/registrants'
                return @{ registrants = @() }
            }

            Get-ZoomMeetingRegistrants -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Status parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ registrants = @() }
            }
        }

        It 'Should accept Status parameter' {
            { Get-ZoomMeetingRegistrants -MeetingId '1234567890' -Status 'approved' } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ registrants = @() }
            }
        }

        It 'Should accept MeetingId from pipeline' {
            $result = '1234567890' | Get-ZoomMeetingRegistrants
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Get-ZoomMeetingRegistrants } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Get-ZoomMeetingRegistrants -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
