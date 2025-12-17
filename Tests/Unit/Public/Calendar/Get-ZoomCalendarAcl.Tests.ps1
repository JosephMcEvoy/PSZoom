BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomCalendarAcl' {
    Context 'When listing ACL rules' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    acl_rules = @(
                        @{
                            id = 'user:user@example.com'
                            role = 'reader'
                            scope = @{
                                type = 'user'
                                value = 'user@example.com'
                            }
                        }
                    )
                    next_page_token = ''
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomCalendarAcl -CalendarId 'primary'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/calendars/primary/acl*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomCalendarAcl -CalendarId 'primary'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return ACL rules' {
            $result = Get-ZoomCalendarAcl -CalendarId 'primary'
            $result | Should -Not -BeNullOrEmpty
            $result.acl_rules | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Query parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ acl_rules = @() } }
        }

        It 'Should include PageSize in query string when provided' {
            Get-ZoomCalendarAcl -CalendarId 'primary' -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=50*'
            }
        }

        It 'Should include NextPageToken in query string when provided' {
            Get-ZoomCalendarAcl -CalendarId 'primary' -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*next_page_token=token123*'
            }
        }

        It 'Should validate PageSize range' {
            $param = (Get-Command Get-ZoomCalendarAcl).Parameters['PageSize']
            $validateRange = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateRangeAttribute] }
            $validateRange.MinRange | Should -Be 1
            $validateRange.MaxRange | Should -Be 300
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ acl_rules = @() } }
        }

        It 'Should accept CalendarId from pipeline' {
            'primary' | Get-ZoomCalendarAcl
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with calendar_id property from pipeline' {
            [PSCustomObject]@{ calendar_id = 'abc123' } | Get-ZoomCalendarAcl
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id property from pipeline' {
            [PSCustomObject]@{ id = 'abc123' } | Get-ZoomCalendarAcl
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ acl_rules = @() } }
        }

        It 'Should accept cal_id alias for CalendarId' {
            { Get-ZoomCalendarAcl -cal_id 'primary' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomCalendarAcl -CalendarId 'primary' -page_size 100 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomCalendarAcl -CalendarId 'primary' -next_page_token 'token' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Calendar not found')
            }

            { Get-ZoomCalendarAcl -CalendarId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
