BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomAccountSettings' {
    Context 'When updating account settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomAccountSettings -AccountId 'abc123' -Settings @{ schedule_meeting = @{ host_video = $true } }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/accounts/abc123/settings*'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomAccountSettings -AccountId 'abc123' -Settings @{ schedule_meeting = @{ host_video = $true } }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should include option query parameter when specified' {
            Update-ZoomAccountSettings -AccountId 'abc123' -Option 'meeting_authentication' -Settings @{ authentication_option = @{ name = 'Test' } }
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*option=meeting_authentication*'
            }
        }

        It 'Should validate Option parameter values' {
            { Update-ZoomAccountSettings -AccountId 'abc123' -Option 'invalid_option' -Settings @{} } | Should -Throw
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ AccountId = 'abc123'; Settings = @{ test = $true } } | Update-ZoomAccountSettings
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
