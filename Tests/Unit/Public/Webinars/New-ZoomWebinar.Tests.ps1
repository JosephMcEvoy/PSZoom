BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomWebinar' {
    Context 'When creating a webinar' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 1234567890
                    host_id = 'host123'
                    topic = 'Test Webinar'
                    type = 5
                    start_url = 'https://zoom.us/s/123456'
                    join_url = 'https://zoom.us/j/123456'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomWebinar -UserId 'user@company.com' -Topic 'Test Webinar'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/users/user@company.com/webinars*'
            }
        }

        It 'Should use POST method' {
            New-ZoomWebinar -UserId 'user@company.com' -Topic 'Test Webinar'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should require UserId parameter' {
            { New-ZoomWebinar -Topic 'Test' } | Should -Throw
        }

        It 'Should require Topic parameter' {
            { New-ZoomWebinar -UserId 'user@company.com' } | Should -Throw
        }

        It 'Should accept pipeline input for UserId' {
            @{ UserId = 'user@company.com'; Topic = 'Test' } | New-ZoomWebinar

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return the response object' {
            $result = New-ZoomWebinar -UserId 'user@company.com' -Topic 'Test Webinar'

            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 1234567890
        }

        It 'Should accept optional StartTime parameter' {
            { New-ZoomWebinar -UserId 'user@company.com' -Topic 'Test' -StartTime '2025-01-15T10:00:00Z' } | Should -Not -Throw
        }

        It 'Should accept optional Duration parameter' {
            { New-ZoomWebinar -UserId 'user@company.com' -Topic 'Test' -Duration 60 } | Should -Not -Throw
        }

        It 'Should accept settings parameters' {
            { New-ZoomWebinar -UserId 'user@company.com' -Topic 'Test' -HostVideo $true -Audio 'both' } | Should -Not -Throw
        }
    }
}
