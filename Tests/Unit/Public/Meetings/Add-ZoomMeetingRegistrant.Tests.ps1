BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomMeetingRegistrant' {
    Context 'When adding a meeting registrant' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'reg123'; registrant_id = 'reg123'; join_url = 'https://zoom.us/j/123' }
            }
        }

        It 'Should complete without error' {
            { Add-ZoomMeetingRegistrant -MeetingId '1234567890' -Email 'user@example.com' -FirstName 'John' -LastName 'Doe' } | Should -Not -Throw
        }

        It 'Should return registrant with join_url' {
            $result = Add-ZoomMeetingRegistrant -MeetingId '1234567890' -Email 'user@example.com' -FirstName 'John' -LastName 'Doe'
            $result.join_url | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct registrants endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/meetings/.*/registrants'
                return @{ id = 'reg123' }
            }

            Add-ZoomMeetingRegistrant -MeetingId '1234567890' -Email 'user@example.com' -FirstName 'John' -LastName 'Doe'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{ id = 'reg123' }
            }

            Add-ZoomMeetingRegistrant -MeetingId '1234567890' -Email 'user@example.com' -FirstName 'John' -LastName 'Doe'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require MeetingId parameter' {
            { Add-ZoomMeetingRegistrant -Email 'user@example.com' -FirstName 'John' -LastName 'Doe' } | Should -Throw
        }

        It 'Should require Email parameter' {
            { Add-ZoomMeetingRegistrant -MeetingId '1234567890' -FirstName 'John' -LastName 'Doe' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Meeting not found')
            }

            { Add-ZoomMeetingRegistrant -MeetingId 'nonexistent' -Email 'user@example.com' -FirstName 'John' -LastName 'Doe' -ErrorAction Stop } | Should -Throw
        }
    }
}
