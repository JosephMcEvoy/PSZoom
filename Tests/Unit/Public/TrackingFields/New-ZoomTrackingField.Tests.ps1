BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomTrackingField' {
    Context 'When creating a tracking field' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'newfield123'; field = 'Department' }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomTrackingField -Field 'Department'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/tracking_fields'
            }
        }

        It 'Should use POST method' {
            New-ZoomTrackingField -Field 'Department'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should return response object' {
            $result = New-ZoomTrackingField -Field 'Department'
            $result.id | Should -Be 'newfield123'
        }

        It 'Should accept recommended values' {
            { New-ZoomTrackingField -Field 'Department' -RecommendedValues @('Sales', 'Engineering') } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ Field = 'Test Field' } | New-ZoomTrackingField
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
