BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinarSettings' {
    Context 'When retrieving webinar settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    host_video = $true
                    panelists_video = $true
                    approval_type = 0
                    audio = 'both'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinarSettings -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/settings*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomWebinarSettings -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomWebinarSettings } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Get-ZoomWebinarSettings

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return settings object' {
            $result = Get-ZoomWebinarSettings -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
            $result.host_video | Should -Be $true
        }
    }
}
