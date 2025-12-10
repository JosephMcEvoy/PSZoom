BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomWebinarPanelists' {
    Context 'When removing all panelists' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomWebinarPanelists -WebinarId 1234567890 -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/panelists*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomWebinarPanelists -WebinarId 1234567890 -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should require WebinarId parameter' {
            { Remove-ZoomWebinarPanelists -Confirm:$false } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Remove-ZoomWebinarPanelists -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
