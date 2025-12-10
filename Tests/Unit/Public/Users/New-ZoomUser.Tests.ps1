BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomUser' {
    Context 'When creating a user with basic parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'newuser123'
                    email = 'newuser@example.com'
                    type = 2
                }
            }
        }

        It 'Should create a new user' {
            $result = New-ZoomUser -Email 'newuser@example.com' -Action 'create' -Type 'Licensed'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return user details' {
            $result = New-ZoomUser -Email 'newuser@example.com' -Action 'create' -Type 'Licensed'
            $result.email | Should -Be 'newuser@example.com'
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $Uri.ToString() | Should -Match 'users$'
                $Method | Should -Be 'POST'
                return @{}
            }

            New-ZoomUser -Email 'newuser@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include action in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.action | Should -Be 'create'
                return @{}
            }

            New-ZoomUser -Email 'newuser@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false
        }

        It 'Should include user_info in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info | Should -Not -BeNullOrEmpty
                $bodyObj.user_info.email | Should -Be 'newuser@example.com'
                return @{}
            }

            New-ZoomUser -Email 'newuser@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false
        }
    }

    Context 'When creating user with different actions' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'user123' }
            }
        }

        It 'Should accept create action' {
            { New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept autoCreate action' {
            { New-ZoomUser -Email 'user@example.com' -Action 'autoCreate' -Type 'Licensed' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept custCreate action' {
            { New-ZoomUser -Email 'user@example.com' -Action 'custCreate' -Type 'Licensed' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept ssoCreate action' {
            { New-ZoomUser -Email 'user@example.com' -Action 'ssoCreate' -Type 'Licensed' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject invalid action values' {
            { New-ZoomUser -Email 'user@example.com' -Action 'invalid' -Type 'Licensed' -Confirm:$false } | Should -Throw
        }
    }

    Context 'When creating user with different types' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                return @{ id = 'user123' }
            }
        }

        It 'Should accept Basic type and convert to 1' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.type | Should -Be 1
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Basic' -Confirm:$false
        }

        It 'Should accept Licensed type and convert to 2' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.type | Should -Be 2
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false
        }

        It 'Should accept Pro type and convert to 2' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.type | Should -Be 2
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Pro' -Confirm:$false
        }

        It 'Should accept None type and convert to 99' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.type | Should -Be 99
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'ssoCreate' -Type 'None' -Confirm:$false
        }

        It 'Should accept Corp type and convert to 99' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.type | Should -Be 99
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'ssoCreate' -Type 'Corp' -Confirm:$false
        }

        It 'Should accept numeric type values' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.type | Should -Be 1
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 1 -Confirm:$false
        }
    }

    Context 'When creating user with optional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'user123' }
            }
        }

        It 'Should include FirstName when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.first_name | Should -Be 'John'
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -FirstName 'John' -Confirm:$false
        }

        It 'Should include LastName when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.last_name | Should -Be 'Doe'
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -LastName 'Doe' -Confirm:$false
        }

        It 'Should include Password when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.password | Should -Be 'SecurePass123!'
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'autoCreate' -Type 'Licensed' -Password 'SecurePass123!' -Confirm:$false
        }

        It 'Should include all optional parameters when provided' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Body, $Method)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.user_info.first_name | Should -Be 'John'
                $bodyObj.user_info.last_name | Should -Be 'Doe'
                $bodyObj.user_info.password | Should -Be 'SecurePass123!'
                return @{}
            }
            New-ZoomUser -Email 'user@example.com' -Action 'autoCreate' -Type 'Licensed' -FirstName 'John' -LastName 'Doe' -Password 'SecurePass123!' -Confirm:$false
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'user123' }
            }
        }

        It 'Should accept Email from pipeline' {
            $result = 'newuser@example.com' | New-ZoomUser -Action 'create' -Type 'Licensed' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with properties from pipeline' {
            $userObject = [PSCustomObject]@{
                Email = 'newuser@example.com'
                Action = 'create'
                Type = 'Licensed'
                FirstName = 'John'
                LastName = 'Doe'
            }
            $result = $userObject | New-ZoomUser -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    id = 'user123'
                    email = 'newuser@example.com'
                }
            }
        }

        It 'Should return Email when Passthru is used' {
            $result = New-ZoomUser -Email 'newuser@example.com' -Action 'create' -Type 'Licensed' -Passthru -Confirm:$false
            $result | Should -Be 'newuser@example.com'
        }

        It 'Should return API response when Passthru is not used' {
            $result = New-ZoomUser -Email 'newuser@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false
            $result.email | Should -Be 'newuser@example.com'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'user123' }
            }
        }

        It 'Should accept EmailAddress alias for Email' {
            { New-ZoomUser -EmailAddress 'user@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept UserId alias for Email' {
            { New-ZoomUser -UserId 'user@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept first_name alias for FirstName' {
            { New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -first_name 'John' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept last_name alias for LastName' {
            { New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -last_name 'Doe' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'user123' }
            }
        }

        It 'Should require Email parameter' {
            { New-ZoomUser -Action 'create' -Type 'Licensed' -Confirm:$false } | Should -Throw
        }

        It 'Should require Action parameter' {
            { New-ZoomUser -Email 'user@example.com' -Type 'Licensed' -Confirm:$false } | Should -Throw
        }

        It 'Should require Type parameter' {
            { New-ZoomUser -Email 'user@example.com' -Action 'create' -Confirm:$false } | Should -Throw
        }

        It 'Should validate Email length (max 128)' {
            $longEmail = 'a' * 120 + '@test.com'
            { New-ZoomUser -Email $longEmail -Action 'create' -Type 'Licensed' -Confirm:$false } | Should -Throw
        }

        It 'Should validate FirstName length (max 64)' {
            $longName = 'a' * 65
            { New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -FirstName $longName -Confirm:$false } | Should -Throw
        }

        It 'Should validate LastName length (max 64)' {
            $longName = 'a' * 65
            { New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -LastName $longName -Confirm:$false } | Should -Throw
        }
    }

    Context 'ShouldProcess support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ id = 'user123' }
            }
        }

        It 'Should support WhatIf' {
            New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should create user when confirmed' {
            New-ZoomUser -Email 'user@example.com' -Action 'create' -Type 'Licensed' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors for duplicate user' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User already exists')
            }

            { New-ZoomUser -Email 'existing@example.com' -Action 'create' -Type 'Licensed' -ErrorAction Stop -Confirm:$false } | Should -Throw
        }

        It 'Should propagate API errors for invalid email' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Invalid email address')
            }

            { New-ZoomUser -Email 'invalid-email' -Action 'create' -Type 'Licensed' -ErrorAction Stop -Confirm:$false } | Should -Throw
        }
    }
}
