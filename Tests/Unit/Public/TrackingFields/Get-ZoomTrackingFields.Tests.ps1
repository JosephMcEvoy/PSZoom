BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomTrackingFields' {
    Context 'When listing tracking fields' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    tracking_fields = @(
                        @{ id = 'field1'; field = 'Department' }
                        @{ id = 'field2'; field = 'Project' }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomTrackingFields
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/tracking_fields'
            }
        }

        It 'Should use GET method' {
            Get-ZoomTrackingFields
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Get'
            }
        }

        It 'Should return response with tracking fields' {
            $result = Get-ZoomTrackingFields
            $result.tracking_fields | Should -HaveCount 2
        }
    }
}
