BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomGroup' {
    Context 'When creating a new group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'newgroup123'
                    name = 'Test Group'
                    total_members = 0
                }
            }
        }

        It 'Should create a group with Name parameter' {
            $result = New-ZoomGroup -Name 'Test Group' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return the created group' {
            $result = New-ZoomGroup -Name 'Test Group' -Confirm:$false
            $result.id | Should -Be 'newgroup123'
            $result.name | Should -Be 'Test Group'
        }

        It 'Should create multiple groups' {
            $result = New-ZoomGroup -Name 'Group1', 'Group2' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct groups endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/groups'
                return @{ id = 'test' }
            }

            New-ZoomGroup -Name 'Test' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use POST method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'POST'
                return @{ id = 'test' }
            }

            New-ZoomGroup -Name 'Test' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'SupportsShouldProcess' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'test' }
            }
        }

        It 'Should support WhatIf' {
            New-ZoomGroup -Name 'Test' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm:$false' {
            { New-ZoomGroup -Name 'Test' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require Name parameter' {
            { New-ZoomGroup -Confirm:$false } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Group creation failed')
            }

            { New-ZoomGroup -Name 'Test' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
