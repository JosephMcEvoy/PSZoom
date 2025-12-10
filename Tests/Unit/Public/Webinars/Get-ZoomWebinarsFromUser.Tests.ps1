BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinarsFromUser' {
    Context 'When retrieving webinars from a user' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 1
                    page_number = 1
                    page_size = 30
                    total_records = 2
                    webinars = @(
                        @{
                            uuid = 'abc123'
                            id = 1234567890
                            host_id = 'user123'
                            topic = 'First Webinar'
                            type = 5
                            start_time = '2025-01-15T10:00:00Z'
                            duration = 60
                            timezone = 'America/Los_Angeles'
                            created_at = '2025-01-01T10:00:00Z'
                            join_url = 'https://zoom.us/j/1234567890'
                        }
                        @{
                            uuid = 'xyz789'
                            id = 9876543210
                            host_id = 'user123'
                            topic = 'Second Webinar'
                            type = 6
                            start_time = '2025-01-22T10:00:00Z'
                            duration = 90
                            timezone = 'America/Los_Angeles'
                            created_at = '2025-01-02T10:00:00Z'
                            join_url = 'https://zoom.us/j/9876543210'
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinarsFromUser -UserId 'user@test.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/users/user@test.com/webinars*'
            }
        }

        It 'Should require UserId parameter' {
            { Get-ZoomWebinarsFromUser } | Should -Throw
        }

        It 'Should accept UserId from pipeline' {
            'user@test.com' | Get-ZoomWebinarsFromUser

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept user_id alias' {
            Get-ZoomWebinarsFromUser -user_id 'user@test.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept user alias' {
            Get-ZoomWebinarsFromUser -user 'user@test.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use default page size of 30' {
            Get-ZoomWebinarsFromUser -UserId 'user@test.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Should accept custom PageSize parameter' {
            Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should use default page number of 1' {
            Get-ZoomWebinarsFromUser -UserId 'user@test.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_number=1'
            }
        }

        It 'Should accept custom PageNumber parameter' {
            Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageNumber 2

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_number=2'
            }
        }

        It 'Should use GET method' {
            Get-ZoomWebinarsFromUser -UserId 'user@test.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomWebinarsFromUser -UserId 'user@test.com'

            $result | Should -Not -BeNullOrEmpty
            $result.webinars | Should -HaveCount 2
            $result.total_records | Should -Be 2
        }

        It 'Should return webinar details with all expected properties' {
            $result = Get-ZoomWebinarsFromUser -UserId 'user@test.com'

            $result.webinars[0].id | Should -Be 1234567890
            $result.webinars[0].topic | Should -Be 'First Webinar'
            $result.webinars[0].host_id | Should -Be 'user123'
            $result.webinars[1].id | Should -Be 9876543210
            $result.webinars[1].topic | Should -Be 'Second Webinar'
        }

        It 'Should handle multiple user IDs' {
            Get-ZoomWebinarsFromUser -UserId 'user1@test.com', 'user2@test.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should construct correct URI for each user' {
            Get-ZoomWebinarsFromUser -UserId 'user1@test.com', 'user2@test.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/users/user1@test.com/webinars*'
            }

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/users/user2@test.com/webinars*'
            }
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ webinars = @() }
            }
        }

        It 'Should validate PageSize range (1-300)' {
            { Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageSize 0 } | Should -Throw
            { Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageSize 301 } | Should -Throw
        }

        It 'Should accept valid PageSize within range' {
            { Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageSize 150 } | Should -Not -Throw
        }

        It 'Should validate PageNumber range (1-300)' {
            { Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageNumber 0 } | Should -Throw
            { Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageNumber 301 } | Should -Throw
        }

        It 'Should accept valid PageNumber within range' {
            { Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageNumber 150 } | Should -Not -Throw
        }

        It 'Should accept UserId as email address' {
            { Get-ZoomWebinarsFromUser -UserId 'user@test.com' } | Should -Not -Throw
        }

        It 'Should accept UserId as user ID string' {
            { Get-ZoomWebinarsFromUser -UserId 'abc123xyz' } | Should -Not -Throw
        }

        It 'Should accept "me" as UserId for user-level apps' {
            { Get-ZoomWebinarsFromUser -UserId 'me' } | Should -Not -Throw
        }
    }

    Context 'When handling users with no webinars' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 0
                    page_number = 1
                    page_size = 30
                    total_records = 0
                    webinars = @()
                }
            }
        }

        It 'Should return empty webinars array' {
            $result = Get-ZoomWebinarsFromUser -UserId 'user@test.com'

            $result.webinars | Should -BeNullOrEmpty
            $result.total_records | Should -Be 0
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: User not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomWebinarsFromUser -UserId 'user@test.com' } | Should -Throw
        }
    }

    Context 'When handling pagination' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                if ($Uri -match 'page_number=1') {
                    return @{
                        page_count = 2
                        page_number = 1
                        page_size = 30
                        total_records = 35
                        webinars = @(
                            @{ id = 1; topic = 'Webinar 1' }
                        )
                    }
                } else {
                    return @{
                        page_count = 2
                        page_number = 2
                        page_size = 30
                        total_records = 35
                        webinars = @(
                            @{ id = 2; topic = 'Webinar 2' }
                        )
                    }
                }
            }
        }

        It 'Should retrieve first page by default' {
            $result = Get-ZoomWebinarsFromUser -UserId 'user@test.com'

            $result.page_number | Should -Be 1
            $result.page_count | Should -Be 2
        }

        It 'Should retrieve specific page when PageNumber is provided' {
            $result = Get-ZoomWebinarsFromUser -UserId 'user@test.com' -PageNumber 2

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_number=2'
            }
        }
    }
}
