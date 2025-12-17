BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomUserCalendarList' {
    Context 'When retrieving user calendar list' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    calendars = @(
                        @{
                            id = 'primary'
                            summary = 'Primary Calendar'
                            selected = $true
                        }
                    )
                    next_page_token = ''
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomUserCalendarList -UserIdentifier 'me'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/calendars/users/me/calendarList*'
            }
        }

        It 'Should use GET method' {
            Get-ZoomUserCalendarList -UserIdentifier 'me'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return calendar list' {
            $result = Get-ZoomUserCalendarList -UserIdentifier 'me'
            $result | Should -Not -BeNullOrEmpty
            $result.calendars | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Query parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ calendars = @() } }
        }

        It 'Should include PageSize in query string when provided' {
            Get-ZoomUserCalendarList -UserIdentifier 'me' -PageSize 50
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*page_size=50*'
            }
        }

        It 'Should include NextPageToken in query string when provided' {
            Get-ZoomUserCalendarList -UserIdentifier 'me' -NextPageToken 'token123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like '*next_page_token=token123*'
            }
        }

        It 'Should validate PageSize range' {
            $param = (Get-Command Get-ZoomUserCalendarList).Parameters['PageSize']
            $validateRange = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateRangeAttribute] }
            $validateRange.MinRange | Should -Be 1
            $validateRange.MaxRange | Should -Be 300
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ calendars = @() } }
        }

        It 'Should accept UserIdentifier from pipeline' {
            'me' | Get-ZoomUserCalendarList
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with user_identifier property from pipeline' {
            [PSCustomObject]@{ user_identifier = 'user@example.com' } | Get-ZoomUserCalendarList
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id property from pipeline' {
            [PSCustomObject]@{ id = 'user123' } | Get-ZoomUserCalendarList
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ calendars = @() } }
        }

        It 'Should accept user_identifier alias for UserIdentifier' {
            { Get-ZoomUserCalendarList -user_identifier 'me' } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserIdentifier' {
            { Get-ZoomUserCalendarList -user_id 'user123' } | Should -Not -Throw
        }

        It 'Should accept user alias for UserIdentifier' {
            { Get-ZoomUserCalendarList -user 'user@example.com' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomUserCalendarList -UserIdentifier 'me' -page_size 100 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomUserCalendarList -UserIdentifier 'me' -next_page_token 'token' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ calendars = @() } }
        }

        It 'Should accept UserIdentifier as first positional parameter' {
            $result = Get-ZoomUserCalendarList 'me'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomUserCalendarList -UserIdentifier 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
