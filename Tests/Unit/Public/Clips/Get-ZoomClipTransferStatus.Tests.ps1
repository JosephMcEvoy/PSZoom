BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomClipTransferStatus' {
    Context 'When getting transfer status' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    task_id = 'task123'
                    status = 'completed'
                    transferred_clips = 15
                }
            }
        }

        It 'Should call API with correct endpoint' {
            Get-ZoomClipTransferStatus -TaskId 'task123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/clips/transfers/task123$'
            }
        }

        It 'Should use GET method' {
            Get-ZoomClipTransferStatus -TaskId 'task123'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return the response object' {
            $result = Get-ZoomClipTransferStatus -TaskId 'task123'

            $result.status | Should -Be 'completed'
            $result.transferred_clips | Should -Be 15
        }
    }

    Context 'When processing multiple task IDs' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ task_id = $TaskId; status = 'completed' }
            }
        }

        It 'Should process array of task IDs' {
            Get-ZoomClipTransferStatus -TaskId 'task1', 'task2', 'task3'

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ task_id = 'task123'; status = 'completed' }
            }
        }

        It 'Should accept TaskId from pipeline' {
            'task123' | Get-ZoomClipTransferStatus

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept task_id from pipeline by property name' {
            [PSCustomObject]@{ task_id = 'task123' } | Get-ZoomClipTransferStatus

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ task_id = 'task123' }
            }
        }

        It 'Should accept task_id alias' {
            { Get-ZoomClipTransferStatus -task_id 'task123' } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Get-ZoomClipTransferStatus -id 'task123' } | Should -Not -Throw
        }
    }
}
