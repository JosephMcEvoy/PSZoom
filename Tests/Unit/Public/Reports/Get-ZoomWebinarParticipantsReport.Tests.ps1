BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinarParticipantsReport' {
    Context 'When retrieving webinar participants report' {
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
                            attentiveness_score = 95
                        }
                        @{
                            id = 'part2'
                            user_id = 'user2'
                            name = 'Participant Two'
                            user_email = 'part2@test.com'
                            join_time = '2025-01-15T10:05:00Z'
                            leave_time = '2025-01-15T10:55:00Z'
                            duration = 3000
                            attentiveness_score = 88
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinarParticipantsReport -WebinarId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/report/webinars/1234567890/participants*'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomWebinarParticipantsReport } | Should -Throw
        }

        It 'Should accept WebinarId from pipeline by property name' {
            [PSCustomObject]@{ WebinarId = '1234567890' } | Get-ZoomWebinarParticipantsReport

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept id alias for WebinarId' {
            Get-ZoomWebinarParticipantsReport -id '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use default page size of 30' {
            Get-ZoomWebinarParticipantsReport -WebinarId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Should accept custom PageSize parameter' {
            Get-ZoomWebinarParticipantsReport -WebinarId '1234567890' -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should include NextPageToken when provided' {
            Get-ZoomWebinarParticipantsReport -WebinarId '1234567890' -NextPageToken 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should not include NextPageToken in URI when not provided' {
            Get-ZoomWebinarParticipantsReport -WebinarId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -notmatch 'next_page_token='
            }
        }

        It 'Should return the response object with participants' {
            $result = Get-ZoomWebinarParticipantsReport -WebinarId '1234567890'

            $result | Should -Not -BeNullOrEmpty
            $result.participants | Should -HaveCount 2
            $result.total_records | Should -Be 2
        }

        It 'Should use GET method' {
            Get-ZoomWebinarParticipantsReport -WebinarId '1234567890'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should handle multiple webinar IDs' {
            Get-ZoomWebinarParticipantsReport -WebinarId '1234567890', '0987654321'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should call API once for each webinar ID' {
            Get-ZoomWebinarParticipantsReport -WebinarId '1234567890', '0987654321'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ participants = @() }
            }
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomWebinarParticipantsReport -WebinarId '1234567890' -PageSize 0 } | Should -Throw
            { Get-ZoomWebinarParticipantsReport -WebinarId '1234567890' -PageSize 301 } | Should -Throw
        }

        It 'Should accept valid PageSize within range' {
            { Get-ZoomWebinarParticipantsReport -WebinarId '1234567890' -PageSize 150 } | Should -Not -Throw
        }

        It 'Should accept WebinarId as string' {
            { Get-ZoomWebinarParticipantsReport -WebinarId '1234567890' } | Should -Not -Throw
        }

        It 'Should accept array of WebinarIds' {
            { Get-ZoomWebinarParticipantsReport -WebinarId @('1234567890', '0987654321') } | Should -Not -Throw
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Webinar not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomWebinarParticipantsReport -WebinarId '1234567890' } | Should -Throw
        }
    }
}
