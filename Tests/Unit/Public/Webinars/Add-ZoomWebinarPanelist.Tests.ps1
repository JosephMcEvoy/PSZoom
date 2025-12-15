BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomWebinarPanelist' {
    Context 'When adding a panelist' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'panelist123'
                    join_url = 'https://zoom.us/w/123456'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Add-ZoomWebinarPanelist -WebinarId 1234567890 -Name 'John Doe' -Email 'john@company.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/panelists*'
            }
        }

        It 'Should use POST method' {
            Add-ZoomWebinarPanelist -WebinarId 1234567890 -Name 'John Doe' -Email 'john@company.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should require WebinarId parameter' {
            { Add-ZoomWebinarPanelist -Name 'John' -Email 'john@company.com' } | Should -Throw
        }

        It 'Should require Name and Email for single panelist' {
            { Add-ZoomWebinarPanelist -WebinarId 1234567890 -Name 'John' } | Should -Throw
        }

        It 'Should accept multiple panelists via Panelists parameter' {
            $panelists = @(@{ name = 'John'; email = 'john@company.com' })
            Add-ZoomWebinarPanelist -WebinarId 1234567890 -Panelists $panelists

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return the response object' {
            $result = Add-ZoomWebinarPanelist -WebinarId 1234567890 -Name 'John Doe' -Email 'john@company.com'

            $result | Should -Not -BeNullOrEmpty
        }
    }
}
