BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomIMGroup' {
    Context 'When creating an IM group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'newgroup123'; name = 'Test Group' }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomIMGroup -Name 'Test Group'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/im/groups'
            }
        }

        It 'Should use POST method' {
            New-ZoomIMGroup -Name 'Test Group'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should return response object' {
            $result = New-ZoomIMGroup -Name 'Test Group'
            $result.id | Should -Be 'newgroup123'
        }

        It 'Should accept optional search parameters' {
            { New-ZoomIMGroup -Name 'Test' -SearchByAccount $true -SearchByDomain $true } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ Name = 'Pipeline Group' } | New-ZoomIMGroup
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
