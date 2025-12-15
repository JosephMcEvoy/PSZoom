BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    $script:mockGroupMembers = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/group-members.json" | ConvertFrom-Json
}

Describe 'Get-ZoomGroupMembers' {
    Context 'When listing group members' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:mockGroupMembers
            }
        }

        It 'Should return group members' {
            $result = Get-ZoomGroupMembers -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return members with expected properties' {
            $result = Get-ZoomGroupMembers -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            $result.members | Should -Not -BeNullOrEmpty
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct members endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/groups/.*/members'
                return @{ members = @() }
            }

            Get-ZoomGroupMembers -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ members = @() }
            }

            Get-ZoomGroupMembers -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ members = @() }
            }
        }

        It 'Should accept GroupId from pipeline by property name' {
            $result = [PSCustomObject]@{ id = 'gVcjZnYYRLDbb5F3VRzxJw' } | Get-ZoomGroupMembers
            $result | Should -Not -BeNullOrEmpty
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pagination parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ members = @() }
            }
        }

        It 'Should accept PageSize parameter' {
            { Get-ZoomGroupMembers -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -PageSize 100 } | Should -Not -Throw
        }

        It 'Should accept NextPageToken parameter' {
            { Get-ZoomGroupMembers -GroupId 'gVcjZnYYRLDbb5F3VRzxJw' -NextPageToken 'abc123' } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        It 'Should require GroupId parameter' {
            { Get-ZoomGroupMembers } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Group not found')
            }

            { Get-ZoomGroupMembers -GroupId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
