BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Start-ZoomClipTransfer' {
    Context 'When transferring clips between users' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    task_id = 'task123'
                    status = 'in_progress'
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Start-ZoomClipTransfer -FromUserId 'user1@example.com' -ToUserId 'user2@example.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/clips/transfers$'
            }
        }

        It 'Should use POST method' {
            Start-ZoomClipTransfer -FromUserId 'user1@example.com' -ToUserId 'user2@example.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should include from_user_id and to_user_id in body' {
            Start-ZoomClipTransfer -FromUserId 'user1@example.com' -ToUserId 'user2@example.com'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -match '"from_user_id"' -and $Body -match '"to_user_id"'
            }
        }

        It 'Should return the response object' {
            $result = Start-ZoomClipTransfer -FromUserId 'user1@example.com' -ToUserId 'user2@example.com'

            $result.task_id | Should -Be 'task123'
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ task_id = 'task123' }
            }
        }

        It 'Should accept from_user_id and to_user_id from pipeline by property name' {
            $input = [PSCustomObject]@{
                from_user_id = 'user1@example.com'
                to_user_id = 'user2@example.com'
            }

            $result = $input | Start-ZoomClipTransfer

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ task_id = 'task123' }
            }
        }

        It 'Should accept from_user_id alias' {
            { Start-ZoomClipTransfer -from_user_id 'user1@example.com' -to_user_id 'user2@example.com' } | Should -Not -Throw
        }
    }
}
