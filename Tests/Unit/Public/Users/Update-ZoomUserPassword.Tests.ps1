BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomUserPassword' {
    Context 'When updating a user password' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com/password'
                $Method | Should -Be 'PUT'
                return @{ status = 'success' }
            }

            Update-ZoomUserPassword -UserId 'testuser@example.com' -Password 'NewPassword123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include password in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.password | Should -Be 'NewPassword123'
                return @{ status = 'success' }
            }

            Update-ZoomUserPassword -UserId 'testuser@example.com' -Password 'NewPassword123' -Confirm:$false
        }

        It 'Should send request body as JSON' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                { $Body | ConvertFrom-Json } | Should -Not -Throw
                return @{ status = 'success' }
            }

            Update-ZoomUserPassword -UserId 'testuser@example.com' -Password 'NewPassword123' -Confirm:$false
        }
    }

    Context 'Password parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept password with minimum length (8 characters)' {
            { Update-ZoomUserPassword -UserId 'user@example.com' -Password 'Pass1234' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept password with maximum length (31 characters)' {
            $maxPassword = 'a' * 31
            { Update-ZoomUserPassword -UserId 'user@example.com' -Password $maxPassword -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject password less than 8 characters' {
            { Update-ZoomUserPassword -UserId 'user@example.com' -Password 'Pass123' -Confirm:$false } | Should -Throw
        }

        It 'Should reject password more than 31 characters' {
            $longPassword = 'a' * 32
            { Update-ZoomUserPassword -UserId 'user@example.com' -Password $longPassword -Confirm:$false } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Update-ZoomUserPassword -Password 'NewPassword123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            @('user1@example.com', 'user2@example.com') | Update-ZoomUserPassword -Password 'NewPassword123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user@example.com' }
            $userObject | Update-ZoomUserPassword -Password 'NewPassword123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'SupportsShouldProcess behavior' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should support WhatIf parameter' {
            Update-ZoomUserPassword -UserId 'user@example.com' -Password 'NewPassword123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm parameter' {
            Update-ZoomUserPassword -UserId 'user@example.com' -Password 'NewPassword123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should return UserId when Passthru is specified' {
            $result = Update-ZoomUserPassword -UserId 'user@example.com' -Password 'NewPassword123' -PassThru -Confirm:$false
            $result | Should -Be 'user@example.com'
        }

        It 'Should return API response when Passthru is not specified' {
            $result = Update-ZoomUserPassword -UserId 'user@example.com' -Password 'NewPassword123' -Confirm:$false
            $result.status | Should -Be 'success'
        }

        It 'Should return last UserId when processing multiple users via pipeline with PassThru' {
            $results = @('user1@example.com', 'user2@example.com') | Update-ZoomUserPassword -Password 'NewPassword123' -PassThru -Confirm:$false
            $results | Should -Contain 'user2@example.com'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Update-ZoomUserPassword -Email 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Emails alias for UserId' {
            { Update-ZoomUserPassword -Emails 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Update-ZoomUserPassword -EmailAddress 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept EmailAddresses alias for UserId' {
            { Update-ZoomUserPassword -EmailAddresses 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Update-ZoomUserPassword -Id 'user123' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept ids alias for UserId' {
            { Update-ZoomUserPassword -ids 'user123' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Update-ZoomUserPassword -user_id 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept user alias for UserId' {
            { Update-ZoomUserPassword -user 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept users alias for UserId' {
            { Update-ZoomUserPassword -users 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept userids alias for UserId' {
            { Update-ZoomUserPassword -userids 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Required parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should require UserId parameter' {
            { Update-ZoomUserPassword -Password 'NewPassword123' -Confirm:$false } | Should -Throw
        }

        It 'Should require Password parameter' {
            { Update-ZoomUserPassword -UserId 'user@example.com' -Confirm:$false } | Should -Throw
        }

        It 'Should accept both required parameters' {
            { Update-ZoomUserPassword -UserId 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId as first positional parameter' {
            { Update-ZoomUserPassword 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Password as second positional parameter' {
            { Update-ZoomUserPassword 'user@example.com' 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Multiple users processing' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should process each user separately' {
            Update-ZoomUserPassword -UserId @('user1@example.com', 'user2@example.com', 'user3@example.com') -Password 'NewPassword123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should call correct endpoint for each user' {
            $callCount = 0
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $Uri.ToString() | Should -Match 'users/user1@example.com/password'
                }
                if ($script:callCount -eq 2) {
                    $Uri.ToString() | Should -Match 'users/user2@example.com/password'
                }
                return @{ status = 'success' }
            }

            Update-ZoomUserPassword -UserId @('user1@example.com', 'user2@example.com') -Password 'NewPassword123' -Confirm:$false
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Update-ZoomUserPassword -UserId 'nonexistent@example.com' -Password 'NewPassword123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle password policy errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Password does not meet requirements')
            }

            { Update-ZoomUserPassword -UserId 'user@example.com' -Password 'WeakPass1' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Update-ZoomUserPassword -UserId 'user@example.com' -Password 'NewPassword123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'UserId length validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId within valid length' {
            { Update-ZoomUserPassword -UserId 'user@example.com' -Password 'NewPassword123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject UserId exceeding 128 characters' {
            $longUserId = 'a' * 129
            { Update-ZoomUserPassword -UserId $longUserId -Password 'NewPassword123' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Request body structure' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should create proper JSON structure' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.PSObject.Properties.Name | Should -Contain 'password'
                $bodyObj.PSObject.Properties.Count | Should -Be 1
                return @{ status = 'success' }
            }

            Update-ZoomUserPassword -UserId 'user@example.com' -Password 'NewPassword123' -Confirm:$false
        }
    }
}
