BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomCalendarAclRule' {
    Context 'When updating an ACL rule' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'user:user@example.com'
                    role = 'writer'
                    scope = @{
                        type = 'user'
                        value = 'user@example.com'
                    }
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Update-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Role 'writer' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/primary/acl/user:user@example.com'
            }
        }

        It 'Should use PATCH method' {
            Update-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Role 'writer' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'PATCH'
            }
        }

        It 'Should return updated ACL rule object' {
            $result = Update-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Role 'writer' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            $result.role | Should -Be 'writer'
        }

        It 'Should include Role in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.role | Should -Be 'owner'
                return @{ id = 'test' }
            }

            Update-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Role 'owner' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should support -WhatIf parameter' {
            Update-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Role 'writer' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support -Confirm parameter' {
            Update-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'user:user@example.com' -Role 'writer' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have ConfirmImpact set to Low' {
            $cmd = Get-Command Update-ZoomCalendarAclRule
            $cmdletBinding = $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'Low'
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept CalendarId from pipeline' {
            'primary' | Update-ZoomCalendarAclRule -AclId 'user:user@example.com' -Role 'writer' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with all properties from pipeline' {
            $obj = [PSCustomObject]@{
                calendar_id = 'primary'
                acl_id = 'user:user@example.com'
                role = 'writer'
            }
            $obj | Update-ZoomCalendarAclRule -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id alias from pipeline' {
            $obj = [PSCustomObject]@{
                calendar_id = 'primary'
                id = 'user:user@example.com'
                role = 'writer'
            }
            $obj | Update-ZoomCalendarAclRule -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept cal_id alias for CalendarId' {
            { Update-ZoomCalendarAclRule -cal_id 'primary' -AclId 'test' -Role 'writer' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept calendar_id alias for CalendarId' {
            { Update-ZoomCalendarAclRule -calendar_id 'primary' -AclId 'test' -Role 'writer' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept acl_id alias for AclId' {
            { Update-ZoomCalendarAclRule -CalendarId 'primary' -acl_id 'test' -Role 'writer' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias for AclId' {
            { Update-ZoomCalendarAclRule -CalendarId 'primary' -id 'test' -Role 'writer' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept CalendarId as first positional parameter' {
            { Update-ZoomCalendarAclRule 'primary' -AclId 'test' -Role 'writer' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept AclId as second positional parameter' {
            { Update-ZoomCalendarAclRule 'primary' 'user:user@example.com' -Role 'writer' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('ACL rule not found')
            }

            { Update-ZoomCalendarAclRule -CalendarId 'primary' -AclId 'nonexistent' -Role 'writer' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
