BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomWebinarPanelists' {
    Context 'When retrieving webinar panelists' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    total_records = 2
                    panelists = @(
                        @{
                            id = 'panelist1'
                            name = 'John Doe'
                            email = 'john@test.com'
                            join_url = 'https://zoom.us/j/123456?tk=token1'
                        }
                        @{
                            id = 'panelist2'
                            name = 'Jane Smith'
                            email = 'jane@test.com'
                            join_url = 'https://zoom.us/j/123456?tk=token2'
                        }
                    )
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomWebinarPanelists -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/panelists'
            }
        }

        It 'Should require WebinarId parameter' {
            { Get-ZoomWebinarPanelists } | Should -Throw
        }

        It 'Should accept WebinarId from pipeline' {
            1234567890 | Get-ZoomWebinarPanelists

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept webinar_id alias' {
            Get-ZoomWebinarPanelists -webinar_id 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Get-ZoomWebinarPanelists -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomWebinarPanelists -WebinarId 1234567890

            $result | Should -Not -BeNullOrEmpty
            $result.total_records | Should -Be 2
            $result.panelists | Should -HaveCount 2
        }

        It 'Should return panelist details with all expected properties' {
            $result = Get-ZoomWebinarPanelists -WebinarId 1234567890

            $result.panelists[0].id | Should -Be 'panelist1'
            $result.panelists[0].name | Should -Be 'John Doe'
            $result.panelists[0].email | Should -Be 'john@test.com'
            $result.panelists[0].join_url | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When validating parameter types' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ panelists = @() }
            }
        }

        It 'Should accept WebinarId as int64' {
            { Get-ZoomWebinarPanelists -WebinarId 1234567890 } | Should -Not -Throw
        }

        It 'Should accept large WebinarId values' {
            $largeId = [int64]9999999999
            { Get-ZoomWebinarPanelists -WebinarId $largeId } | Should -Not -Throw
        }

        It 'Should accept OccurrenceId as string' {
            { Get-ZoomWebinarPanelists -WebinarId 1234567890 -OccurrenceId 'occurrence123' } | Should -Not -Throw
        }

        It 'Should accept ShowPreviousOccurences as boolean' {
            { Get-ZoomWebinarPanelists -WebinarId 1234567890 -ShowPreviousOccurences $true } | Should -Not -Throw
        }
    }

    Context 'When handling webinars with no panelists' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    total_records = 0
                    panelists = @()
                }
            }
        }

        It 'Should return empty panelists array' {
            $result = Get-ZoomWebinarPanelists -WebinarId 1234567890

            $result.panelists | Should -BeNullOrEmpty
            $result.total_records | Should -Be 0
        }
    }

    Context 'When handling errors' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw 'API Error: Webinar not found'
            }
        }

        It 'Should throw error when API call fails' {
            { Get-ZoomWebinarPanelists -WebinarId 1234567890 } | Should -Throw
        }
    }

    Context 'When constructing API endpoint' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ panelists = @() }
            }
        }

        It 'Should construct correct URI with webinar ID' {
            Get-ZoomWebinarPanelists -WebinarId 1234567890

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890/panelists'
            }
        }

        It 'Should construct URI for different webinar IDs' {
            Get-ZoomWebinarPanelists -WebinarId 9876543210

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/9876543210/panelists'
            }
        }
    }

    Context 'When retrieving panelists from multiple webinars' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ panelists = @() }
            }
        }

        It 'Should handle pipeline input for multiple webinars' {
            $webinarIds = @(1234567890, 9876543210)
            $webinarIds | Get-ZoomWebinarPanelists

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }
}
