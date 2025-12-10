BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomMeetingRecordings' {
    Context 'When removing meeting recordings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Remove-ZoomMeetingRecordings -MeetingId '1234567890' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct recordings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/recordings'
                return @{}
            }

            Remove-ZoomMeetingRecordings -MeetingId '1234567890' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use DELETE method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'DELETE'
                return @{}
            }

            Remove-ZoomMeetingRecordings -MeetingId '1234567890' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include action in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'action='
                return @{}
            }

            Remove-ZoomMeetingRecordings -MeetingId '1234567890' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Action parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should default to trash action' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'action=trash'
                return @{}
            }

            Remove-ZoomMeetingRecordings -MeetingId '1234567890' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept delete action' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'action=delete'
                return @{}
            }

            Remove-ZoomMeetingRecordings -MeetingId '1234567890' -Action 'delete' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should validate Action values' {
            { Remove-ZoomMeetingRecordings -MeetingId '1234567890' -Action 'invalid' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept MeetingId from pipeline' {
            { '1234567890' | Remove-ZoomMeetingRecordings -Confirm:$false } | Should -Not -Throw
        }

        It 'Should process multiple MeetingIds' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }

            @('meeting1', 'meeting2') | Remove-ZoomMeetingRecordings -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept meeting_id alias' {
            { Remove-ZoomMeetingRecordings -meeting_id '1234567890' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Remove-ZoomMeetingRecordings -id '1234567890' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess support' {
        It 'Should support WhatIf' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }

            Remove-ZoomMeetingRecordings -MeetingId '1234567890' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Recording not found')
            }

            { Remove-ZoomMeetingRecordings -MeetingId 'nonexistent' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
