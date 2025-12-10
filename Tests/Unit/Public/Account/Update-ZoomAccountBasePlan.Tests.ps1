BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomAccountBasePlan' {
    Context 'When updating the base plan' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomAccountBasePlan -AccountId 'abc123' -Type 'pro' -Hosts 10
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/accounts/abc123/plans/base*'
            }
        }

        It 'Should use PUT method' {
            Update-ZoomAccountBasePlan -AccountId 'abc123' -Type 'pro' -Hosts 10
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Put'
            }
        }

        It 'Should require Type parameter' {
            { Update-ZoomAccountBasePlan -AccountId 'abc123' -Hosts 10 } | Should -Throw
        }

        It 'Should require Hosts parameter' {
            { Update-ZoomAccountBasePlan -AccountId 'abc123' -Type 'pro' } | Should -Throw
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ AccountId = 'abc123'; Type = 'pro'; Hosts = 10 } | Update-ZoomAccountBasePlan
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
