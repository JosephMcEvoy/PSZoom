BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomMeetingParticipantsReport' {
    Context 'When retrieving meeting participants report' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 1
                    page_size = 30
                    total_records = 2
                    next_page_token = ''
                    participants = @(
                        @{
                            id = 'part1'
                            user_id = 'user1'
                            name = 'Participant One'
                            user_email = 'part1@test.com'
                            join_time = '2025-01-15T10:00:00Z'
                            leave_time = '2025-01-15T11:00:00Z'
                            duration = 3600
                        }
                        @{
                            id = 'part2'
                            user_id = 'user2'
                            name = 'Participant Two'
                            user_email = 'part2@test.com'
                            join_time = '2025-01-15T10:05:00Z'
                            leave_time = '2025-01-15T10:55:00Z'
                            duration = 3000
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomMeetingParticipantsReport -MeetingId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/report/meetings/1234567890/participants*'
            }
        }

        It 'Should require MeetingId parameter' {
            { Get-ZoomMeetingParticipantsReport } | Should -Throw
        }

        It 'Should accept MeetingId from pipeline by property name' {
            [PSCustomObject]@{ MeetingId = '1234567890' } | Get-ZoomMeetingParticipantsReport

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use default page size of 30' {
            Get-ZoomMeetingParticipantsReport -MeetingId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Should accept custom PageSize parameter' {
            Get-ZoomMeetingParticipantsReport -MeetingId '1234567890' -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should include NextPageToken when provided' {
            Get-ZoomMeetingParticipantsReport -MeetingId '1234567890' -NextPageToken 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should return the response object with participants' {
            $result = Get-ZoomMeetingParticipantsReport -MeetingId '1234567890'

            $result | Should -Not -BeNullOrEmpty
            $result.participants | Should -HaveCount 2
            $result.total_records | Should -Be 2
        }

        It 'Should use GET method' {
            Get-ZoomMeetingParticipantsReport -MeetingId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should handle multiple meeting IDs' {
            Get-ZoomMeetingParticipantsReport -MeetingId '1234567890', '0987654321'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'When using CombineAllPages parameter' {
        BeforeEach {
            Mock Get-ZoomMeetingParticipantsReport -ModuleName PSZoom {
                if ($PageNumber -eq 1 -or -not $NextPageToken) {
                    return @{
                        page_count = 2
                        participants = @(
                            @{ id = 'part1' }
                            @{ id = 'part2' }
                        )
                        next_page_token = 'token123'
                    }
                } else {
                    return @{
                        page_count = 2
                        participants = @(
                            @{ id = 'part3' }
                            @{ id = 'part4' }
                        )
                        next_page_token = ''
                    }
                }
            }
        }

        It 'Should combine participants from all pages' {
            $result = Get-ZoomMeetingParticipantsReport -MeetingId '1234567890' -CombineAllPages

            $result.participants | Should -HaveCount 4
        }

        It 'Should set PageSize to 300 automatically' {
            Get-ZoomMeetingParticipantsReport -MeetingId '1234567890' -CombineAllPages

            Should -Invoke Get-ZoomMeetingParticipantsReport -ModuleName PSZoom -ParameterFilter {
                $PageSize -eq 300
            }
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ participants = @() }
            }
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomMeetingParticipantsReport -MeetingId '1234567890' -PageSize 0 } | Should -Throw
            { Get-ZoomMeetingParticipantsReport -MeetingId '1234567890' -PageSize 301 } | Should -Throw
        }

        It 'Should accept valid PageSize within range' {
            { Get-ZoomMeetingParticipantsReport -MeetingId '1234567890' -PageSize 150 } | Should -Not -Throw
        }

        It 'Should accept id alias for MeetingId' {
            Get-ZoomMeetingParticipantsReport -id '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Meeting not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomMeetingParticipantsReport -MeetingId '1234567890' } | Should -Throw
        }
    }
}
