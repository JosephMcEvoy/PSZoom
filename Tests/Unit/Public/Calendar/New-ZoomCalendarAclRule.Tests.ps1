BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomCalendarAclRule' {
    Context 'When creating an ACL rule' {
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
            New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType 'user' -ScopeValue 'user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/calendars/primary/acl'
            }
        }

        It 'Should use POST method' {
            New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType 'user' -ScopeValue 'user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'POST'
            }
        }

        It 'Should return ACL rule object' {
            $result = New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType 'user' -ScopeValue 'user@example.com' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
            $result.id | Should -Be 'user:user@example.com'
        }

        It 'Should include request body with required fields' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.role | Should -Be 'writer'
                $bodyObj.scope.type | Should -Be 'group'
                return @{ id = 'test' }
            }

            New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'writer' -ScopeType 'group' -ScopeValue 'team@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include ScopeValue in body when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.scope.value | Should -Be 'user@example.com'
                return @{ id = 'test' }
            }

            New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType 'user' -ScopeValue 'user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'ScopeType validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept valid ScopeType values' {
            @('user', 'group', 'domain', 'default') | ForEach-Object {
                { New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType $_ -Confirm:$false } | Should -Not -Throw
            }
        }

        It 'Should have ValidateSet attribute on ScopeType' {
            $param = (Get-Command New-ZoomCalendarAclRule).Parameters['ScopeType']
            $param.Attributes.ValidateSetAttribute | Should -Not -BeNullOrEmpty
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should support -WhatIf parameter' {
            New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType 'user' -ScopeValue 'user@example.com' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support -Confirm parameter' {
            New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType 'user' -ScopeValue 'user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept CalendarId from pipeline' {
            'primary' | New-ZoomCalendarAclRule -Role 'reader' -ScopeType 'user' -ScopeValue 'user@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with properties from pipeline' {
            $obj = [PSCustomObject]@{
                calendar_id = 'primary'
                role = 'reader'
                scope_type = 'user'
                scope_value = 'user@example.com'
            }
            $obj | New-ZoomCalendarAclRule -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'test' } }
        }

        It 'Should accept cal_id alias for CalendarId' {
            { New-ZoomCalendarAclRule -cal_id 'primary' -Role 'reader' -ScopeType 'user' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept scope_type alias for ScopeType' {
            { New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -scope_type 'user' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept scope_value alias for ScopeValue' {
            { New-ZoomCalendarAclRule -CalendarId 'primary' -Role 'reader' -ScopeType 'user' -scope_value 'test@example.com' -Confirm:$false } | Should -Not -Throw
        }
    }
}
