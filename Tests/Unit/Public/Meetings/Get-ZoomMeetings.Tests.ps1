BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomMeetings' {
    Context 'When listing meetings' {
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

        It 'Should return meeting list' {
            $result = Get-ZoomMeetings
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept Type parameter' {
            { Get-ZoomMeetings -Type 'past' } | Should -Not -Throw
        }

        It 'Should accept live Type' {
            { Get-ZoomMeetings -Type 'live' } | Should -Not -Throw
        }

        It 'Should accept pastOne Type' {
            { Get-ZoomMeetings -Type 'pastOne' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct metrics/meetings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/metrics/meetings'
                return @{ meetings = @() }
            }

            Get-ZoomMeetings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ meetings = @() }
            }

            Get-ZoomMeetings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Date range parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ meetings = @() }
            }
        }

        It 'Should accept From parameter' {
            { Get-ZoomMeetings -From (Get-Date).AddDays(-7) } | Should -Not -Throw
        }

        It 'Should accept To parameter' {
            { Get-ZoomMeetings -To (Get-Date) } | Should -Not -Throw
        }

        It 'Should accept PageSize parameter' {
            { Get-ZoomMeetings -PageSize 100 } | Should -Not -Throw
        }
    }

    Context 'CombineAllPages parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 1
                    total_records = 1
                    meetings = @(@{ id = '123' })
                }
            }
        }

        It 'Should accept CombineAllPages switch' {
            { Get-ZoomMeetings -CombineAllPages } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should handle API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API Error')
            }

            { Get-ZoomMeetings -ErrorAction Stop } | Should -Throw
        }
    }
}
