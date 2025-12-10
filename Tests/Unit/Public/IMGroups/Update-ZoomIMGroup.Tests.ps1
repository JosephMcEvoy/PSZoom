BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomIMGroup' {
    Context 'When updating an IM group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomIMGroup -GroupId 'abc123' -Name 'Updated Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/im/groups/abc123*'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomIMGroup -GroupId 'abc123' -Name 'Updated Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should not call API when no optional parameters provided' {
            Update-ZoomIMGroup -GroupId 'abc123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should accept search parameters' {
            Update-ZoomIMGroup -GroupId 'abc123' -SearchByAccount $true
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ GroupId = 'abc123'; Name = 'New Name' } | Update-ZoomIMGroup
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
