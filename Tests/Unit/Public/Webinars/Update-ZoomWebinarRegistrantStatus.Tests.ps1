BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomWebinarRegistrantStatus' {
    Context 'When updating registrant status' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomWebinarRegistrantStatus -WebinarId 1234567890 -Action 'approve' -Registrants @(@{id='reg123'})

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/registrants/status*'
            }
        }

        It 'Should use PUT method' {
            Update-ZoomWebinarRegistrantStatus -WebinarId 1234567890 -Action 'approve' -Registrants @(@{id='reg123'})

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Put'
            }
        }

        It 'Should require WebinarId parameter' {
            { Update-ZoomWebinarRegistrantStatus -Action 'approve' -Registrants @(@{id='reg123'}) } | Should -Throw
        }

        It 'Should require Action parameter' {
            { Update-ZoomWebinarRegistrantStatus -WebinarId 1234567890 -Registrants @(@{id='reg123'}) } | Should -Throw
        }

        It 'Should require Registrants parameter' {
            { Update-ZoomWebinarRegistrantStatus -WebinarId 1234567890 -Action 'approve' } | Should -Throw
        }

        It 'Should accept valid Action values' {
            { Update-ZoomWebinarRegistrantStatus -WebinarId 1234567890 -Action 'approve' -Registrants @(@{id='reg123'}) } | Should -Not -Throw
            { Update-ZoomWebinarRegistrantStatus -WebinarId 1234567890 -Action 'cancel' -Registrants @(@{id='reg123'}) } | Should -Not -Throw
            { Update-ZoomWebinarRegistrantStatus -WebinarId 1234567890 -Action 'deny' -Registrants @(@{id='reg123'}) } | Should -Not -Throw
        }

        It 'Should reject invalid Action values' {
            { Update-ZoomWebinarRegistrantStatus -WebinarId 1234567890 -Action 'invalid' -Registrants @(@{id='reg123'}) } | Should -Throw
        }
    }
}
