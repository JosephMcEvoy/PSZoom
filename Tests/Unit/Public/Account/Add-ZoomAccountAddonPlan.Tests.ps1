BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomAccountAddonPlan' {
    Context 'When adding an addon plan' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Add-ZoomAccountAddonPlan -AccountId 'abc123' -Type 'large_meeting_500' -Hosts 5
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/accounts/abc123/plans/addons*'
            }
        }

        It 'Should use POST method' {
            Add-ZoomAccountAddonPlan -AccountId 'abc123' -Type 'large_meeting_500' -Hosts 5
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should require Type parameter' {
            { Add-ZoomAccountAddonPlan -AccountId 'abc123' -Hosts 5 } | Should -Throw
        }

        It 'Should require Hosts parameter' {
            { Add-ZoomAccountAddonPlan -AccountId 'abc123' -Type 'large_meeting_500' } | Should -Throw
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ AccountId = 'abc123'; Type = 'large_meeting_500'; Hosts = 5 } | Add-ZoomAccountAddonPlan
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
