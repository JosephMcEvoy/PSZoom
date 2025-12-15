BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomRoomLocations' {
    Context 'When retrieving Zoom Room locations' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    page_size = 30
                    next_page_token = ''
                    locations = @(
                        @{
                            id = 'AhH8cXHQSxs0ehdPyZbJLQ'
                            name = 'Coglin St'
                            parent_location_id = 'KSq88chVTeS4cSCLtrt8fA'
                            type = 'campus'
                        }
                        @{
                            id = 'WU5haagyThudC9HGfeJo3g'
                            name = 'London'
                            parent_location_id = 'FGLxfHIKSlmfM_AFdHoGpg'
                            type = 'city'
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomRoomLocations

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/rooms/locations*'
            }
        }

        It 'Should not require any parameters' {
            { Get-ZoomRoomLocations } | Should -Not -Throw
        }

        It 'Should use default page size of 30' {
            Get-ZoomRoomLocations

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Should accept custom PageSize parameter' {
            Get-ZoomRoomLocations -PageSize 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should accept page_size alias' {
            Get-ZoomRoomLocations -page_size 100

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }

        It 'Should include ParentLocationId in query when provided' {
            Get-ZoomRoomLocations -ParentLocationId '_AFlXw-FTwGS7BrO1QupVA'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'parent_location_id=_AFlXw-FTwGS7BrO1QupVA'
            }
        }

        It 'Should include NextPageToken in query when provided' {
            Get-ZoomRoomLocations -NextPageToken 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should accept next_page_token alias' {
            Get-ZoomRoomLocations -next_page_token 'token123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Should use GET method' {
            Get-ZoomRoomLocations

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return only locations array by default' {
            $result = Get-ZoomRoomLocations

            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
            $result[0].name | Should -Be 'Coglin St'
            $result[0].type | Should -Be 'campus'
        }

        It 'Should return full response when Full switch is used' {
            $result = Get-ZoomRoomLocations -Full

            $result | Should -Not -BeNullOrEmpty
            $result.page_size | Should -Be 30
            $result.locations | Should -HaveCount 2
        }
    }

    Context 'When validating parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ locations = @() }
            }
        }

        It 'Should validate PageSize range (30-300)' {
            { Get-ZoomRoomLocations -PageSize 29 } | Should -Throw
            { Get-ZoomRoomLocations -PageSize 301 } | Should -Throw
        }

        It 'Should accept valid PageSize within range' {
            { Get-ZoomRoomLocations -PageSize 100 } | Should -Not -Throw
        }

        It 'Should accept ParentLocationId as optional parameter' {
            { Get-ZoomRoomLocations -ParentLocationId 'loc123' } | Should -Not -Throw
        }

        It 'Should accept pipeline input for PageSize by property name' {
            [PSCustomObject]@{ PageSize = 100 } | Get-ZoomRoomLocations

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'page_size=100'
            }
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Unauthorized'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomRoomLocations } | Should -Throw
        }
    }

}
