BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomH323Device' {
    Context 'When updating an H.323/SIP device' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomH323Device -DeviceId 'abc123' -Name 'Updated Room'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/h323/devices/abc123*'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomH323Device -DeviceId 'abc123' -Name 'Updated Room'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should not call API when no optional parameters provided' {
            Update-ZoomH323Device -DeviceId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ DeviceId = 'abc123'; Name = 'New Name' } | Update-ZoomH323Device
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
