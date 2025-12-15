BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
    # Create SecureString password for tests
    $script:TestPassword = ConvertTo-SecureString 'Test123!' -AsPlainText -Force
}

Describe 'New-ZoomAccount' {
    Context 'When creating a new sub account' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'abc123'
                    owner_email = 'owner@company.com'
                    created_at = '2023-01-01T00:00:00Z'
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password $script:TestPassword -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/accounts'
            }
        }

        It 'Should use POST method' {
            New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password $script:TestPassword -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should return response object' {
            $result = New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password $script:TestPassword -Confirm:$false
            $result.id | Should -Be 'abc123'
        }

        It 'Should accept optional AccountName parameter' {
            { New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password $script:TestPassword -AccountName 'Test Company' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept optional VanityUrl parameter' {
            { New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password $script:TestPassword -VanityUrl 'testcompany' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Email Validation' {
        It 'Should reject invalid email format' {
            { New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'invalid-email' -Password $script:TestPassword -Confirm:$false } | Should -Throw
        }

        It 'Should accept valid email format' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
            { New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'valid@company.com' -Password $script:TestPassword -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'ShouldProcess Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return @{ id = 'abc123' } }
        }

        It 'Should support -WhatIf parameter' {
            $result = New-ZoomAccount -FirstName 'John' -LastName 'Doe' -Email 'john@company.com' -Password $script:TestPassword -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }
    }

    Context 'Password Security' {
        It 'Should require SecureString for password' {
            $param = (Get-Command New-ZoomAccount).Parameters['Password']
            $param.ParameterType.Name | Should -Be 'SecureString'
        }
    }
}
