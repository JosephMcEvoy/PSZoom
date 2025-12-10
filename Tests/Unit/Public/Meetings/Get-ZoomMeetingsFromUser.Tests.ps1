BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomMeetingsFromUser' {
    Context 'When listing meetings for a user' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 1
                    page_size = 30
                    total_records = 2
                    meetings = @(
                        @{ id = '1234567890'; topic = 'Test Meeting 1' }
                        @{ id = '0987654321'; topic = 'Test Meeting 2' }
                    )
                }
            }
        }

        It 'Should return meeting list for user' {
            $result = Get-ZoomMeetingsFromUser -UserId 'user@example.com'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct users/meetings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/users/.*/meetings'
                return @{ meetings = @() }
            }

            Get-ZoomMeetingsFromUser -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ meetings = @() }
            }

            Get-ZoomMeetingsFromUser -UserId 'user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ meetings = @() }
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'user@example.com' | Get-ZoomMeetingsFromUser
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Type parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ meetings = @() }
            }
        }

        It 'Should accept scheduled type' {
            { Get-ZoomMeetingsFromUser -UserId 'user@example.com' -Type 'scheduled' } | Should -Not -Throw
        }

        It 'Should accept live type' {
            { Get-ZoomMeetingsFromUser -UserId 'user@example.com' -Type 'live' } | Should -Not -Throw
        }

        It 'Should accept upcoming type' {
            { Get-ZoomMeetingsFromUser -UserId 'user@example.com' -Type 'upcoming' } | Should -Not -Throw
        }
    }

    Context 'Pagination parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ meetings = @() }
            }
        }

        It 'Should accept PageSize parameter' {
            { Get-ZoomMeetingsFromUser -UserId 'user@example.com' -PageSize 50 } | Should -Not -Throw
        }

        It 'Should accept PageNumber parameter' {
            { Get-ZoomMeetingsFromUser -UserId 'user@example.com' -PageNumber 2 } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require UserId parameter' {
            { Get-ZoomMeetingsFromUser } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomMeetingsFromUser -UserId 'nonexistent@example.com' -ErrorAction Stop } | Should -Throw
        }
    }
}
