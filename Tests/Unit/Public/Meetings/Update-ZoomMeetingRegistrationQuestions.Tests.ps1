BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomMeetingRegistrationQuestions' {
    Context 'When updating registration questions' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Update-ZoomMeetingRegistrationQuestions -MeetingId '1234567890' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct registrants/questions endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/registrants/questions'
                return @{}
            }

            Update-ZoomMeetingRegistrationQuestions -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomMeetingRegistrationQuestions -MeetingId '1234567890'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Update-ZoomMeetingRegistrationQuestions } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Update-ZoomMeetingRegistrationQuestions -MeetingId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
