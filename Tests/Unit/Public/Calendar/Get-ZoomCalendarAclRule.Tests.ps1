BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomCalendarAclRule' {
    Context 'When retrieving a specific ACL rule' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'user:user@example.com'
                    role = 'reader'
                    scope = @{
                        type = 'user'
                        value = 'user@example.com'
                    }
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Get-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/primary/acl/user:user@example.com'
            }
        }

        It 'Should use GET method' {
            Get-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'GET'
            }
        }

        It 'Should return ACL rule object' {
            $result = Get-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com'
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'user:user@example.com'
            $result.role | Should -Be 'reader'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'user:user@example.com'
                    role = 'reader'
                }
            }
        }

        It 'Should accept CalendarId from pipeline' {
            'primary' | Get-ZoomCalendarAclRule -AclId 'user:user@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with both properties from pipeline' {
            $obj = [PSCustomObject]@{
                calendar_id = 'primary'
                acl_id = 'user:user@example.com'
            }
            $obj | Get-ZoomCalendarAclRule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id alias from pipeline' {
            $obj = [PSCustomObject]@{
                calendar_id = 'primary'
                id = 'user:user@example.com'
            }
            $obj | Get-ZoomCalendarAclRule
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'test' }
            }
        }

        It 'Should accept cal_id alias for CalendarId' {
            { Get-ZoomCalendarAclRule -cal_id 'primary' -AclId 'test' } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias for CalendarId' {
            { Get-ZoomCalendarAclRule -calendar_id 'primary' -AclId 'test' } | Should -Not -Throw
        }

        It 'Should accept acl_id alias for AclId' {
            { Get-ZoomCalendarAclRule -CalendarId 'primary' -acl_id 'test' } | Should -Not -Throw
        }

        It 'Should accept id alias for AclId' {
            { Get-ZoomCalendarAclRule -CalendarId 'primary' -id 'test' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'test' }
            }
        }

        It 'Should accept CalendarId as first positional parameter' {
            { Get-ZoomCalendarAclRule 'primary' -AclId 'test' } | Should -Not -Throw
        }

        It 'Should accept AclId as second positional parameter' {
            { Get-ZoomCalendarAclRule 'primary' 'user:user@example.com' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('ACL rule not found')
            }

            { Get-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
