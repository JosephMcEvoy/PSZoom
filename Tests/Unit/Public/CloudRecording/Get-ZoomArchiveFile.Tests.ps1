BeforeAll {
    Import-Module $PSScriptRoot/../../../../PSZoom/PSZoom.psd1 -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    
    $mockResponsePath = "$PSScriptRoot/../../../Fixtures/MockResponses/archive-file-get.json"
    if (Test-Path $mockResponsePath) {
        $script:MockResponse = Get-Content -Path $mockResponsePath -Raw | ConvertFrom-Json
    } else {
        $script:MockResponse = @{
            from = '2023-01-01'
            to = '2023-01-31'
            page_size = 30
            next_page_token = ''
            meetings = @(
                @{
                    uuid = 'abc123'
                    id = 123456789
                    account_id = 'account123'
                    host_id = 'host123'
                    topic = 'Test Meeting'
                    type = 2
                    start_time = '2023-01-15T10:00:00Z'
                    timezone = 'America/New_York'
                    duration = 60
                    total_size = 1048576
                    recording_count = 2
                    archive_files = @(
                        @{
                            id = 'file1'
                            recording_id = 'rec1'
                            file_type = 'MP4'
                            file_size = 524288
                            download_url = 'https://example.com/file1.mp4'
                            status = 'completed'
                            recording_type = 'shared_screen_with_speaker_view'
                        }
                    )
                }
            )
        }
    }
}

Describe 'Get-ZoomArchiveFile' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $script:MockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns archive file data' {
            $result = Get-ZoomArchiveFile
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Returns expected properties' {
            $result = Get-ZoomArchiveFile
            $result | Should -Not -BeNullOrEmpty
            $result.PSObject.Properties.Name | Should -Contain 'meetings'
        }

        It 'Calls Invoke-ZoomRestMethod' {
            Get-ZoomArchiveFile
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct base URL' {
            Get-ZoomArchiveFile
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'archive_files'
            }
        }

        It 'Uses GET method' {
            Get-ZoomArchiveFile
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Includes page_size parameter in query string' {
            Get-ZoomArchiveFile -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_size=50'
            }
        }

        It 'Uses default page_size of 30' {
            Get-ZoomArchiveFile
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_size=30'
            }
        }

        It 'Includes next_page_token when specified' {
            Get-ZoomArchiveFile -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'next_page_token=token123'
            }
        }

        It 'Includes from date when specified' {
            Get-ZoomArchiveFile -From '2023-01-01'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'from=2023-01-01'
            }
        }

        It 'Includes to date when specified' {
            Get-ZoomArchiveFile -To '2023-01-31'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'to=2023-01-31'
            }
        }

        It 'Includes query_date_type when specified' {
            Get-ZoomArchiveFile -QueryDateType 'meeting_time'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'query_date_type=meeting_time'
            }
        }

        It 'Includes group_id when specified' {
            Get-ZoomArchiveFile -GroupId 'group123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'group_id=group123'
            }
        }

        It 'Includes group_ids when specified' {
            Get-ZoomArchiveFile -GroupIds 'group1,group2'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'group_ids=group1'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Accepts valid PageSize within range' {
            { Get-ZoomArchiveFile -PageSize 100 } | Should -Not -Throw
        }

        It 'Accepts minimum PageSize of 1' {
            { Get-ZoomArchiveFile -PageSize 1 } | Should -Not -Throw
        }

        It 'Accepts maximum PageSize of 300' {
            { Get-ZoomArchiveFile -PageSize 300 } | Should -Not -Throw
        }

        It 'Rejects PageSize below minimum' {
            { Get-ZoomArchiveFile -PageSize 0 } | Should -Throw
        }

        It 'Rejects PageSize above maximum' {
            { Get-ZoomArchiveFile -PageSize 301 } | Should -Throw
        }

        It 'Accepts valid QueryDateType meeting_time' {
            { Get-ZoomArchiveFile -QueryDateType 'meeting_time' } | Should -Not -Throw
        }

        It 'Accepts valid QueryDateType archive_time' {
            { Get-ZoomArchiveFile -QueryDateType 'archive_time' } | Should -Not -Throw
        }

        It 'Rejects invalid QueryDateType' {
            { Get-ZoomArchiveFile -QueryDateType 'invalid_type' } | Should -Throw
        }
    }

    Context 'Parameter Aliases' {
        It 'Accepts page_size alias for PageSize' {
            { Get-ZoomArchiveFile -page_size 50 } | Should -Not -Throw
        }

        It 'Accepts next_page_token alias for NextPageToken' {
            { Get-ZoomArchiveFile -next_page_token 'token123' } | Should -Not -Throw
        }

        It 'Accepts query_date_type alias for QueryDateType' {
            { Get-ZoomArchiveFile -query_date_type 'meeting_time' } | Should -Not -Throw
        }

        It 'Accepts group_id alias for GroupId' {
            { Get-ZoomArchiveFile -group_id 'group123' } | Should -Not -Throw
        }

        It 'Accepts group_ids alias for GroupIds' {
            { Get-ZoomArchiveFile -group_ids 'group1,group2' } | Should -Not -Throw
        }

        It 'Accepts from_date alias for From parameter' {
            { Get-ZoomArchiveFile -from_date '2023-01-01' } | Should -Not -Throw
        }

        It 'Accepts to_date alias for To parameter' {
            { Get-ZoomArchiveFile -to_date '2023-01-31' } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts PageSize from pipeline by property name' {
            $params = [PSCustomObject]@{ PageSize = 50 }
            { $params | Get-ZoomArchiveFile } | Should -Not -Throw
        }

        It 'Accepts From from pipeline by property name' {
            $params = [PSCustomObject]@{ From = '2023-01-01' }
            { $params | Get-ZoomArchiveFile } | Should -Not -Throw
        }

        It 'Accepts To from pipeline by property name' {
            $params = [PSCustomObject]@{ To = '2023-01-31' }
            { $params | Get-ZoomArchiveFile } | Should -Not -Throw
        }

        It 'Accepts multiple parameters from pipeline' {
            $params = [PSCustomObject]@{
                From = '2023-01-01'
                To = '2023-01-31'
                PageSize = 100
            }
            { $params | Get-ZoomArchiveFile } | Should -Not -Throw
        }
    }

    Context 'Date Range Queries' {
        It 'Constructs URL with both from and to dates' {
            Get-ZoomArchiveFile -From '2023-01-01' -To '2023-01-31'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'from=2023-01-01' -and $Uri -match 'to=2023-01-31'
            }
        }

        It 'Constructs URL with date range and query type' {
            Get-ZoomArchiveFile -From '2023-01-01' -To '2023-01-31' -QueryDateType 'archive_time'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'from=2023-01-01' -and
                $Uri -match 'to=2023-01-31' -and
                $Uri -match 'query_date_type=archive_time'
            }
        }
    }

    Context 'Group Filtering' {
        It 'Constructs URL with group_id' {
            Get-ZoomArchiveFile -GroupId 'group123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'group_id=group123'
            }
        }

        It 'Constructs URL with group_ids for multiple groups' {
            Get-ZoomArchiveFile -GroupIds 'group1,group2,group3'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'group_ids='
            }
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error'
            } -ParameterFilter { $Uri -match 'error' }
        }

        It 'Handles API errors gracefully' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Unauthorized'
            }
            { Get-ZoomArchiveFile } | Should -Throw
        }
    }

    Context 'Pagination' {
        It 'Includes next_page_token for pagination' {
            Get-ZoomArchiveFile -NextPageToken 'abcdef123456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'next_page_token=abcdef123456'
            }
        }

        It 'Combines pagination with other parameters' {
            Get-ZoomArchiveFile -PageSize 100 -NextPageToken 'token123' -From '2023-01-01'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'page_size=100' -and 
                $Uri -match 'next_page_token=token123' -and 
                $Uri -match 'from=2023-01-01'
            }
        }
    }
}
