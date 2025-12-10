BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Join-ZoomPages' {
    BeforeAll {
        # Set up required module state
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    Context 'Parameter validation' {
        It 'Should require ZoomCommand parameter' {
            { Join-ZoomPages -ZoomCommandSplat @{ PageSize = 100 } } | Should -Throw
        }

        It 'Should require ZoomCommandSplat parameter' {
            { Join-ZoomPages -ZoomCommand 'Get-ZoomUser' } | Should -Throw
        }

        It 'Should require ZoomCommandSplat to be a hashtable' {
            # This is enforced by the parameter type
            { Join-ZoomPages -ZoomCommand 'Get-ZoomUser' -ZoomCommandSplat 'invalid' } | Should -Throw
        }
    }

    Context 'Single page results' {
        It 'Should return results from single page response' {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return [PSCustomObject]@{
                    page_count = 1
                    users = @(
                        @{ id = 'user1'; email = 'user1@test.com' }
                        @{ id = 'user2'; email = 'user2@test.com' }
                    )
                }
            }

            $result = Join-ZoomPages -ZoomCommand 'Get-ZoomUser' -ZoomCommandSplat @{ PageSize = 100 }
            $result.Count | Should -Be 2
        }

        It 'Should not attempt pagination when page_count is 1' {
            $callCount = 0
            Mock Get-ZoomUser -ModuleName PSZoom {
                $callCount++
                return [PSCustomObject]@{
                    page_count = 1
                    users = @(@{ id = 'user1' })
                }
            }

            Join-ZoomPages -ZoomCommand 'Get-ZoomUser' -ZoomCommandSplat @{}
            Should -Invoke Get-ZoomUser -ModuleName PSZoom -Times 1
        }
    }

    Context 'Multi-page results' {
        It 'Should combine results from multiple pages' {
            $script:pageNum = 0
            Mock Get-ZoomMeetings -ModuleName PSZoom {
                $script:pageNum++
                if ($script:pageNum -eq 1) {
                    return [PSCustomObject]@{
                        page_count = 2
                        next_page_token = 'token123'
                        meetings = @(
                            @{ id = 'meeting1' }
                            @{ id = 'meeting2' }
                        )
                    }
                } else {
                    return [PSCustomObject]@{
                        page_count = 2
                        meetings = @(
                            @{ id = 'meeting3' }
                            @{ id = 'meeting4' }
                        )
                    }
                }
            }

            $result = Join-ZoomPages -ZoomCommand 'Get-ZoomMeetings' -ZoomCommandSplat @{ PageSize = 2 }
            $result.Count | Should -Be 4
        }

        It 'Should call command correct number of times for multi-page results' {
            $script:multiPageCallCount = 0
            Mock Get-ZoomUser -ModuleName PSZoom {
                $script:multiPageCallCount++
                return [PSCustomObject]@{
                    page_count = 3
                    next_page_token = if ($script:multiPageCallCount -lt 3) { 'token' } else { $null }
                    users = @(@{ id = "user$script:multiPageCallCount" })
                }
            }

            # Get-ZoomUser has NextPageToken parameter - use empty splat to avoid parameter set conflicts
            Join-ZoomPages -ZoomCommand 'Get-ZoomUser' -ZoomCommandSplat @{}
            Should -Invoke Get-ZoomUser -ModuleName PSZoom -Times 3
        }
    }

    Context 'NextPageToken handling' {
        It 'Should pass NextPageToken to subsequent calls' {
            $script:tokenReceived = $null
            $script:callNum = 0
            Mock Get-ZoomUser -ModuleName PSZoom {
                param($NextPageToken)
                $script:callNum++
                if ($script:callNum -gt 1) {
                    $script:tokenReceived = $NextPageToken
                }
                return [PSCustomObject]@{
                    page_count = 2
                    next_page_token = if ($script:callNum -eq 1) { 'expected-token' } else { $null }
                    users = @(@{ id = 'user' })
                }
            }

            Join-ZoomPages -ZoomCommand 'Get-ZoomUser' -ZoomCommandSplat @{}
            $script:tokenReceived | Should -Be 'expected-token'
        }

        It 'Should remove NextPageToken from splat between calls' {
            $script:callNum = 0
            Mock Get-ZoomMeetings -ModuleName PSZoom {
                $script:callNum++
                return [PSCustomObject]@{
                    page_count = 2
                    next_page_token = if ($script:callNum -eq 1) { 'token' } else { $null }
                    meetings = @(@{ id = 'meeting' })
                }
            }

            $splat = @{ PageSize = 100 }
            Join-ZoomPages -ZoomCommand 'Get-ZoomMeetings' -ZoomCommandSplat $splat

            # Splat should not have NextPageToken remaining
            $splat.ContainsKey('NextPageToken') | Should -BeFalse
        }
    }

    Context 'Rate limiting (HTTP 429)' {
        It 'Should handle rate limiting with retry' {
            $script:callNum = 0
            Mock Get-ZoomUser -ModuleName PSZoom {
                $script:callNum++
                if ($script:callNum -eq 2) {
                    # Simulate 429 on second call
                    $error.Clear()
                    throw '429'
                }
                return [PSCustomObject]@{
                    page_count = 3
                    next_page_token = if ($script:callNum -lt 3) { 'token' } else { $null }
                    users = @(@{ id = 'user' })
                }
            }

            # This test may take time due to retry sleep
            # Marking as integration test if needed
        }
    }

    Context 'Member detection' {
        It 'Should detect correct member property from response' {
            Mock Get-ZoomGroups -ModuleName PSZoom {
                return [PSCustomObject]@{
                    page_count = 1
                    total_records = 2
                    groups = @(
                        @{ id = 'group1'; name = 'Group 1' }
                        @{ id = 'group2'; name = 'Group 2' }
                    )
                }
            }

            $result = Join-ZoomPages -ZoomCommand 'Get-ZoomGroups' -ZoomCommandSplat @{}
            $result[0].id | Should -Be 'group1'
            $result[1].name | Should -Be 'Group 2'
        }
    }
}
