BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomSchedulerEvent' {
    Context 'When deleting a scheduler event' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call API with correct endpoint' {
            Remove-ZoomSchedulerEvent -EventId 'event123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'v2/scheduler/events/event123$'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomSchedulerEvent -EventId 'event123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should return true on successful deletion' {
            $result = Remove-ZoomSchedulerEvent -EventId 'event123' -Confirm:$false

            $result | Should -Be $true
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should support WhatIf' {
            Remove-ZoomSchedulerEvent -EventId 'event123' -WhatIf

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm:$false' {
            Remove-ZoomSchedulerEvent -EventId 'event123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept EventId from pipeline' {
            'event123' | Remove-ZoomSchedulerEvent -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept event_id from pipeline by property name' {
            [PSCustomObject]@{ event_id = 'event123' } | Remove-ZoomSchedulerEvent -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept event_id alias' {
            { Remove-ZoomSchedulerEvent -event_id 'event123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias' {
            { Remove-ZoomSchedulerEvent -id 'event123' -Confirm:$false } | Should -Not -Throw
        }
    }
}
