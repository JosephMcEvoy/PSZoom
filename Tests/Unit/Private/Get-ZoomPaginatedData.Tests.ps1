BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Get-ZoomPaginatedData' {
    BeforeAll {
        # Set up required module state within module scope
        InModuleScope PSZoom {
            $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
            $script:ZoomURI = 'zoom.us'
        }
    }

    Context 'Parameter validation' {
        It 'Should require URI parameter' {
            InModuleScope PSZoom {
                { Get-ZoomPaginatedData } | Should -Throw
            }
        }

        It 'Should accept PageSize between 1 and 100' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    return @{ total_records = 0 }
                }
                { Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users' -PageSize 50 } | Should -Not -Throw
            }
        }

        It 'Should reject PageSize less than 1' {
            InModuleScope PSZoom {
                { Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users' -PageSize 0 } | Should -Throw
            }
        }

        It 'Should reject PageSize greater than 100' {
            InModuleScope PSZoom {
                { Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users' -PageSize 101 } | Should -Throw
            }
        }
    }

    Context 'AllData parameter set' {
        It 'Should retrieve all data when no pagination token returned' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    return @{
                        total_records = 2
                        users = @(
                            @{ id = 'user1'; email = 'user1@test.com' }
                            @{ id = 'user2'; email = 'user2@test.com' }
                        )
                    }
                }

                $result = Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users'
                $result.Count | Should -Be 2
            }
        }

        It 'Should aggregate data across multiple pages' {
            InModuleScope PSZoom {
                $script:callCount = 0
                Mock Invoke-ZoomRestMethod {
                    $script:callCount++
                    if ($script:callCount -eq 1) {
                        return @{
                            total_records = 4
                            next_page_token = 'token123'
                            users = @(
                                @{ id = 'user1' }
                                @{ id = 'user2' }
                            )
                        }
                    } else {
                        return @{
                            total_records = 4
                            users = @(
                                @{ id = 'user3' }
                                @{ id = 'user4' }
                            )
                        }
                    }
                }

                $result = Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users'
                $result.Count | Should -Be 4
            }
        }

        It 'Should include additional query statements in request' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    param($Uri)
                    $Uri.ToString() | Should -Match 'status=active'
                    return @{ total_records = 0 }
                }

                Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users' -AdditionalQueryStatements @{ status = 'active' }
                Should -Invoke Invoke-ZoomRestMethod -Times 1
            }
        }
    }

    Context 'SelectedRecord parameter set' {
        It 'Should retrieve specific record by ObjectId' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    return @{ id = 'user123'; email = 'test@test.com' }
                }

                $result = Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users' -ObjectId 'user123'
                $result.id | Should -Be 'user123'
            }
        }

        It 'Should retrieve multiple records when multiple ObjectIds provided' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    param($Uri)
                    $id = $Uri.ToString().Split('/')[-1]
                    return @{ id = $id }
                }

                $result = Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users' -ObjectId @('user1', 'user2', 'user3')
                $result.Count | Should -Be 3
            }
        }

        It 'Should accept ObjectId from pipeline' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    return @{ id = 'pipelineuser' }
                }

                $result = 'pipelineuser' | Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users'
                $result.id | Should -Be 'pipelineuser'
            }
        }
    }

    Context 'NextRecords parameter set' {
        It 'Should use NextPageToken when provided' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    param($Uri)
                    $Uri.ToString() | Should -Match 'next_page_token=abc123'
                    return @{
                        total_records = 2
                        users = @(@{ id = 'user1' }, @{ id = 'user2' })
                    }
                }

                Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users' -NextPageToken 'abc123'
                Should -Invoke Invoke-ZoomRestMethod -Times 1
            }
        }

        It 'Should respect PageSize parameter' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    param($Uri)
                    $Uri.ToString() | Should -Match 'page_size=50'
                    return @{ total_records = 0 }
                }

                Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users' -PageSize 50
                Should -Invoke Invoke-ZoomRestMethod -Times 1
            }
        }
    }

    Context 'Response property extraction' {
        It 'Should extract correct property from response with users' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    return @{
                        total_records = 1
                        page_size = 30
                        users = @(@{ id = 'user1'; name = 'Test User' })
                    }
                }

                $result = Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/users'
                $result[0].id | Should -Be 'user1'
                $result[0].name | Should -Be 'Test User'
            }
        }

        It 'Should return full response when no total_records present' {
            InModuleScope PSZoom {
                Mock Invoke-ZoomRestMethod {
                    return @{
                        id = 'meeting123'
                        topic = 'Test Meeting'
                    }
                }

                $result = Get-ZoomPaginatedData -URI 'https://api.zoom.us/v2/meetings/123'
                $result.id | Should -Be 'meeting123'
            }
        }
    }
}
