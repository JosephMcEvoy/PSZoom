BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomGroups' {
    Context 'When listing groups' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    total_records = 2
                    groups = @(
                        @{ id = 'group1'; name = 'Group One'; total_members = 10 }
                        @{ id = 'group2'; name = 'Group Two'; total_members = 5 }
                    )
                }
            }
        }

        It 'Should return groups array by default' {
            $result = Get-ZoomGroups
            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 2
        }

        It 'Should return groups with expected properties' {
            $result = Get-ZoomGroups
            $result[0].id | Should -Be 'group1'
            $result[0].name | Should -Be 'Group One'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct groups endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/groups'
                return @{ groups = @() }
            }

            Get-ZoomGroups
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{ groups = @() }
            }

            Get-ZoomGroups
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'FullApiResponse parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    total_records = 2
                    groups = @(
                        @{ id = 'group1'; name = 'Group One' }
                    )
                }
            }
        }

        It 'Should return full response with FullApiResponse switch' {
            $result = Get-ZoomGroups -FullApiResponse
            $result.total_records | Should -Be 2
            $result.groups | Should -Not -BeNullOrEmpty
        }

        It 'Should return only groups array without FullApiResponse' {
            $result = Get-ZoomGroups
            # By default returns groups array, not full response
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('API Error')
            }

            { Get-ZoomGroups -ErrorAction Stop } | Should -Throw
        }
    }
}
