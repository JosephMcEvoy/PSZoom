BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinarRegistrants' {
    Context 'When retrieving webinar registrants' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_count = 1
                    page_size = 30
                    total_records = 2
                    registrants = @(
                        @{ id = 'reg1'; email = 'user1@company.com'; first_name = 'John' }
                        @{ id = 'reg2'; email = 'user2@company.com'; first_name = 'Jane' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinarRegistrants -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/registrants*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomWebinarRegistrants -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomWebinarRegistrants } | Should -Throw
        }

        It 'Should accept Status parameter' {
            Get-ZoomWebinarRegistrants -WebinarId 1234567890 -Status 'pending'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'status=pending'
            }
        }

        It 'Should accept PageSize parameter' {
            Get-ZoomWebinarRegistrants -WebinarId 1234567890 -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should return registrants' {
            $result = Get-ZoomWebinarRegistrants -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
            $result.total_records | Should -Be 2
        }
    }
}
