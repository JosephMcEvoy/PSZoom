BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomSchedulerAvailabilities' {
    Context 'When listing scheduler availabilities' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    availabilities = @(
                        @{ id = 'avail1'; name = 'Work Hours' }
                        @{ id = 'avail2'; name = 'After Hours' }
                    )
                    page_size = 30
                }
            }
        }

        It 'Should return availabilities list' {
            $result = Get-ZoomSchedulerAvailabilities
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple availabilities' {
            $result = Get-ZoomSchedulerAvailabilities
            $result.availabilities.Count | Should -BeGreaterThan 0
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct availabilities endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/scheduler/availability'
                return @{}
            }

            Get-ZoomSchedulerAvailabilities
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{}
            }

            Get-ZoomSchedulerAvailabilities
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Optional parameters' {
        It 'Should include PageSize in query string when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'page_size=50'
                return @{}
            }

            Get-ZoomSchedulerAvailabilities -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include NextPageToken in query string when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'next_page_token=token123'
                return @{}
            }

            Get-ZoomSchedulerAvailabilities -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should not include PageSize in query string when not provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Not -Match 'page_size='
                return @{}
            }

            Get-ZoomSchedulerAvailabilities
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should validate PageSize range' {
            { Get-ZoomSchedulerAvailabilities -PageSize 0 } | Should -Throw
            { Get-ZoomSchedulerAvailabilities -PageSize 101 } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ availabilities = @() }
            }
        }

        It 'Should accept object with page_size property from pipeline' {
            $paginationObject = [PSCustomObject]@{ page_size = 50 }
            $result = $paginationObject | Get-ZoomSchedulerAvailabilities
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with next_page_token property from pipeline' {
            $paginationObject = [PSCustomObject]@{ next_page_token = 'token123' }
            $result = $paginationObject | Get-ZoomSchedulerAvailabilities
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomSchedulerAvailabilities -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomSchedulerAvailabilities -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Failed to retrieve availabilities')
            }

            { Get-ZoomSchedulerAvailabilities -ErrorAction Stop } | Should -Throw
        }
    }
}
