BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomMeetingRecordingFile' {
    Context 'When removing a recording file' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should remove recording file' {
            { Remove-ZoomMeetingRecordingFile -MeetingId '1234567890' -RecordingId 'rec123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should remove multiple recording files' {
            Remove-ZoomMeetingRecordingFile -MeetingId '1234567890' -RecordingId 'rec1', 'rec2' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct recordings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/recordings/.*'
                return @{}
            }

            Remove-ZoomMeetingRecordingFile -MeetingId '1234567890' -RecordingId 'rec123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use DELETE method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'DELETE'
                return @{}
            }

            Remove-ZoomMeetingRecordingFile -MeetingId '1234567890' -RecordingId 'rec123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Action parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept trash action' {
            { Remove-ZoomMeetingRecordingFile -MeetingId '1234567890' -RecordingId 'rec123' -Action 'trash' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept delete action' {
            { Remove-ZoomMeetingRecordingFile -MeetingId '1234567890' -RecordingId 'rec123' -Action 'delete' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'SupportsShouldProcess' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            Remove-ZoomMeetingRecordingFile -MeetingId '1234567890' -RecordingId 'rec123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Remove-ZoomMeetingRecordingFile -RecordingId 'rec123' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found')
            }

            { Remove-ZoomMeetingRecordingFile -MeetingId 'nonexistent' -RecordingId 'rec' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
