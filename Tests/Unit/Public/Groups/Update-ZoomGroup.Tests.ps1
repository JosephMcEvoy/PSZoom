BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomGroup' {
    Context 'When updating a group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should complete without error' {
            { Update-ZoomGroup -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -Name 'New Engineering' } | Should -Not -Throw
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct group endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/groups/'
                return @{}
            }

            Update-ZoomGroup -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -Name 'New Engineering'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use PATCH method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'PATCH'
                return @{}
            }

            Update-ZoomGroup -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -Name 'New Engineering'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept GroupId from pipeline' {
            { 'gVcjZnYYRLDbb5F3VRzxJw' | Update-ZoomGroup -Name 'New Name' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require GroupId parameter' {
            { Update-ZoomGroup -Name 'New Name' } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Group not found')
            }

            { Update-ZoomGroup -GroupId 'nonexistent' -Name 'Test' -ErrorAction Stop } | Should -Throw
        }
    }
}
