BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomWebinar' {
    Context 'When deleting a webinar' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomWebinar -WebinarId 1234567890 -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/webinars/1234567890*'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomWebinar -WebinarId 1234567890 -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Delete'
            }
        }

        It 'Should require WebinarId parameter' {
            { Remove-ZoomWebinar -Confirm:$false } | Should -Throw
        }

        It 'Should accept pipeline input' {
            1234567890 | Remove-ZoomWebinar -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept webinar_id alias' {
            Remove-ZoomWebinar -webinar_id 1234567890 -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include OccurrenceId in query when provided' {
            Remove-ZoomWebinar -WebinarId 1234567890 -OccurrenceId 'occur123' -Confirm:$false

            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -match 'occurrence_id=occur123'
            }
        }

        It 'Should return WebinarId when Passthru is used' {
            $result = Remove-ZoomWebinar -WebinarId 1234567890 -Passthru -Confirm:$false

            $result | Should -Be 1234567890
        }
    }
}
