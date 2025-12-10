BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    $script:MockGroupGet = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/group-get.json" | ConvertFrom-Json
}

Describe 'Get-ZoomGroup' {
    Context 'When retrieving a group by GroupId' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockGroupGet
            }
        }

        It 'Should return group details' {
            $result = Get-ZoomGroup -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return group with correct id' {
            $result = Get-ZoomGroup -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            $result.id | Should -Be 'gVcjZnYYRLDbb5F3VRzxJw'
        }

        It 'Should return group with correct name' {
            $result = Get-ZoomGroup -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            $result.name | Should -Be 'Engineering'
        }

        It 'Should return group with total_members' {
            $result = Get-ZoomGroup -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            $result.total_members | Should -Be 25
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct group endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/groups/'
                return $script:MockGroupGet
            }

            Get-ZoomGroup -GroupId 'testgroup123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return $script:MockGroupGet
            }

            Get-ZoomGroup -GroupId 'gVcjZnYYRLDbb5F3VRzxJw'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockGroupGet
            }
        }

        It 'Should accept object with id property from pipeline' {
            $groupObject = [PSCustomObject]@{ id = 'gVcjZnYYRLDbb5F3VRzxJw' }
            $result = $groupObject | Get-ZoomGroup
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockGroupGet
            }
        }

        It 'Should accept group_id alias for GroupId' {
            { Get-ZoomGroup -group_id 'testgroup' } | Should -Not -Throw
        }

        It 'Should accept group alias for GroupId' {
            { Get-ZoomGroup -group 'testgroup' } | Should -Not -Throw
        }

        It 'Should accept id alias for GroupId' {
            { Get-ZoomGroup -id 'testgroup' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockGroupGet
            }
        }

        It 'Should accept GroupId as first positional parameter' {
            $result = Get-ZoomGroup 'gVcjZnYYRLDbb5F3VRzxJw'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'Should require GroupId parameter' {
            { Get-ZoomGroup } | Should -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Group not found')
            }

            { Get-ZoomGroup -GroupId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
