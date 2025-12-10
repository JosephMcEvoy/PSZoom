BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomWebinarPanelist' {
    Context 'When removing a panelist' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomWebinarPanelist -WebinarId 1234567890 -PanelistId 'panelist123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/panelists/panelist123*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomWebinarPanelist -WebinarId 1234567890 -PanelistId 'panelist123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should require WebinarId parameter' {
            { Remove-ZoomWebinarPanelist -PanelistId 'panelist123' -Confirm:$false } | Should -Throw
        }

        It 'Should require PanelistId parameter' {
            { Remove-ZoomWebinarPanelist -WebinarId 1234567890 -Confirm:$false } | Should -Throw
        }

        It 'Should accept pipeline input for PanelistId' {
            'panelist123' | Remove-ZoomWebinarPanelist -WebinarId 1234567890 -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
