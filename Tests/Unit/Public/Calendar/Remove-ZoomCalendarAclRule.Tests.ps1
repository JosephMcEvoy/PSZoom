BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomCalendarAclRule' {
    Context 'When removing an ACL rule' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Remove-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/primary/acl/user:user@example.com'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should return true on success' {
            $result = Remove-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Confirm:$false
            $result | Should -Be $true
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should support -WhatIf parameter' {
            Remove-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support -Confirm parameter' {
            Remove-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have ConfirmImpact set to High' {
            $cmd = Get-Command Remove-ZoomCalendarAclRule
            $cmd.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept CalendarId from pipeline' {
            'primary' | Remove-ZoomCalendarAclRule -AclId 'user:user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with both properties from pipeline' {
            $obj = [PSCustomObject]@{
                calendar_id = 'primary'
                acl_id = 'user:user@example.com'
            }
            $obj | Remove-ZoomCalendarAclRule -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id alias from pipeline' {
            $obj = [PSCustomObject]@{
                calendar_id = 'primary'
                id = 'user:user@example.com'
            }
            $obj | Remove-ZoomCalendarAclRule -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept cal_id alias for CalendarId' {
            { Remove-ZoomCalendarAclRule -cal_id 'primary' -AclId 'test' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias for CalendarId' {
            { Remove-ZoomCalendarAclRule -calendar_id 'primary' -AclId 'test' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept acl_id alias for AclId' {
            { Remove-ZoomCalendarAclRule -CalendarId 'primary' -acl_id 'test' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias for AclId' {
            { Remove-ZoomCalendarAclRule -CalendarId 'primary' -id 'test' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{} }
        }

        It 'Should accept CalendarId as first positional parameter' {
            { Remove-ZoomCalendarAclRule 'primary' -AclId 'test' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept AclId as second positional parameter' {
            { Remove-ZoomCalendarAclRule 'primary' 'user:user@example.com' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('ACL rule not found')
            }

            { Remove-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'nonexistent' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
