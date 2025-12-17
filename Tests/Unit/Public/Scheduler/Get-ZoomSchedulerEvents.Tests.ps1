BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomSchedulerEvents' {
    Context 'When listing scheduler events' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    events = @(
                        @{ id = 'event1'; title = 'Team Meeting' }
                        @{ id = 'event2'; title = 'Client Call' }
                    )
                    page_size = 30
                }
            }
        }

        It 'Should return events list' {
            $result = Get-ZoomSchedulerEvents
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple events' {
            $result = Get-ZoomSchedulerEvents
            $result.events.Count | Should -BeGreaterThan 0
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct events endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/scheduler/events'
                return @{}
            }

            Get-ZoomSchedulerEvents
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{}
            }

            Get-ZoomSchedulerEvents
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

            Get-ZoomSchedulerEvents -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include NextPageToken in query string when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'next_page_token=token123'
                return @{}
            }

            Get-ZoomSchedulerEvents -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include Status in query string when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'status=confirmed'
                return @{}
            }

            Get-ZoomSchedulerEvents -Status 'confirmed'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should not include PageSize in query string when not provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Not -Match 'page_size='
                return @{}
            }

            Get-ZoomSchedulerEvents
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should validate PageSize range' {
            { Get-ZoomSchedulerEvents -PageSize 0 } | Should -Throw
            { Get-ZoomSchedulerEvents -PageSize 101 } | Should -Throw
        }

        It 'Should include multiple parameters in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'page_size=25'
                $Uri.ToString() | Should -Match 'status=pending'
                return @{}
            }

            Get-ZoomSchedulerEvents -PageSize 25 -Status 'pending'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ events = @() }
            }
        }

        It 'Should accept object with page_size property from pipeline' {
            $paginationObject = [PSCustomObject]@{ page_size = 50 }
            $result = $paginationObject | Get-ZoomSchedulerEvents
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with next_page_token property from pipeline' {
            $paginationObject = [PSCustomObject]@{ next_page_token = 'token123' }
            $result = $paginationObject | Get-ZoomSchedulerEvents
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with status property from pipeline' {
            $filterObject = [PSCustomObject]@{ status = 'confirmed' }
            $result = $filterObject | Get-ZoomSchedulerEvents
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
            { Get-ZoomSchedulerEvents -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomSchedulerEvents -next_page_token 'token123' } | Should -Not -Throw
        }

        It 'Should accept event_status alias for Status' {
            { Get-ZoomSchedulerEvents -event_status 'confirmed' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Failed to retrieve events')
            }

            { Get-ZoomSchedulerEvents -ErrorAction Stop } | Should -Throw
        }
    }
}
