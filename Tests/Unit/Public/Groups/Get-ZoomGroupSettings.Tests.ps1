BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    $script:mockGroupSettings = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/group-settings.json" | ConvertFrom-Json
}

Describe 'Get-ZoomGroupSettings' {
    Context 'When retrieving group settings' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:mockGroupSettings
            }
        }

        It 'Should return group settings' {
            $result = Get-ZoomGroupSettings -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return settings with schedule_meeting property' {
            $result = Get-ZoomGroupSettings -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            $result.schedule_meeting | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct settings endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/groups/.*/settings'
                return @{}
            }

            Get-ZoomGroupSettings -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{}
            }

            Get-ZoomGroupSettings -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ schedule_meeting = @{} }
            }
        }

        It 'Should accept GroupId from pipeline by property name' {
            $result = [PSCustomObject]@{ id = 'gVcjZnYYRLDbb5F3VRzxJw' } | Get-ZoomGroupSettings
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter validation' {
        It 'Should require GroupId parameter' {
            { Get-ZoomGroupSettings } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Group not found')
            }

            { Get-ZoomGroupSettings -GroupId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
