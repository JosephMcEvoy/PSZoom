BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomCalendarColors' {
    Context 'When getting calendar colors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    calendar = @{
                        '1' = @{ background = '#ac725e'; foreground = '#1d1d1d' }
                        '2' = @{ background = '#d06b64'; foreground = '#1d1d1d' }
                        '3' = @{ background = '#f83a22'; foreground = '#1d1d1d' }
                    }
                    event = @{
                        '1' = @{ background = '#a4bdfc'; foreground = '#1d1d1d' }
                        '2' = @{ background = '#7ae7bf'; foreground = '#1d1d1d' }
                    }
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Get-ZoomCalendarColors

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/calendars/colors$'
            }
        }

        It 'Should use GET method' {
            Get-ZoomCalendarColors

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return the response object with calendar colors' {
            $result = Get-ZoomCalendarColors

            $result.calendar | Should -Not -BeNullOrEmpty
        }

        It 'Should return the response object with event colors' {
            $result = Get-ZoomCalendarColors

            $result.event | Should -Not -BeNullOrEmpty
        }
    }
}
