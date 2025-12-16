BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomContactGroup' {
    Context 'When updating a contact group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomContactGroup -GroupId 'grp123' -Name 'Updated Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/contacts/groups/grp123'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomContactGroup -GroupId 'grp123' -Name 'Updated Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Patch'
            }
        }

        It 'Should include name in body when specified' {
            Update-ZoomContactGroup -GroupId 'grp123' -Name 'Updated Name'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.name -eq 'Updated Name'
            }
        }

        It 'Should include privacy in body when specified' {
            Update-ZoomContactGroup -GroupId 'grp123' -Privacy 3
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.privacy -eq 3
            }
        }

        It 'Should include description in body when specified' {
            Update-ZoomContactGroup -GroupId 'grp123' -Description 'New description'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.description -eq 'New description'
            }
        }

        It 'Should return true on success' {
            $result = Update-ZoomContactGroup -GroupId 'grp123' -Name 'Updated'
            $result | Should -Be $true
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should accept GroupId from pipeline' {
            'grp123' | Update-ZoomContactGroup -Name 'Updated'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
