BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomWebinarStatus' {
    Context 'When updating webinar status' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomWebinarStatus -WebinarId 1234567890 -Action 'end'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/status*'
            }
        }

        It 'Should use PUT method' {
            Update-ZoomWebinarStatus -WebinarId 1234567890 -Action 'end'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Put'
            }
        }

        It 'Should require WebinarId parameter' {
            { Update-ZoomWebinarStatus -Action 'end' } | Should -Throw
        }

        It 'Should require Action parameter' {
            { Update-ZoomWebinarStatus -WebinarId 1234567890 } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Update-ZoomWebinarStatus -Action 'end'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should only accept valid Action values' {
            { Update-ZoomWebinarStatus -WebinarId 1234567890 -Action 'invalid' } | Should -Throw
        }
    }
}
