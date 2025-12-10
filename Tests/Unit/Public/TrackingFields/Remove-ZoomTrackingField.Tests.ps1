BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomTrackingField' {
    Context 'When deleting a tracking field' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomTrackingField -FieldId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/tracking_fields/abc123*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomTrackingField -FieldId 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should support ShouldProcess' {
            Remove-ZoomTrackingField -FieldId 'abc123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ FieldId = 'abc123' } | Remove-ZoomTrackingField -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
