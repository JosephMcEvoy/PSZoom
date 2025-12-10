BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomUserStatus' {
    Context 'When activating a user' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com/status'
                $Method | Should -Be 'PUT'
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId 'testuser@example.com' -Action 'activate' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include action in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.action | Should -Be 'activate'
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId 'testuser@example.com' -Action 'activate' -Confirm:$false
        }

        It 'Should convert action to lowercase' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.action | Should -Be 'activate'
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId 'testuser@example.com' -Action 'Activate' -Confirm:$false
        }
    }

    Context 'When deactivating a user' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should call API with deactivate action' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.action | Should -Be 'deactivate'
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId 'testuser@example.com' -Action 'deactivate' -Confirm:$false
        }
    }

    Context 'Action parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept activate action' {
            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept deactivate action' {
            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'deactivate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject invalid action values' {
            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'invalid' -Confirm:$false } | Should -Throw
        }

        It 'Should reject delete action' {
            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'delete' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Update-ZoomUserStatus -Action 'activate' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            @('user1@example.com', 'user2@example.com') | Update-ZoomUserStatus -Action 'activate' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user@example.com' }
            $userObject | Update-ZoomUserStatus -Action 'activate' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with user_id property from pipeline' {
            $userObject = [PSCustomObject]@{ user_id = 'user@example.com' }
            $userObject | Update-ZoomUserStatus -Action 'activate' -Confirm:$false
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
            Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should support Confirm parameter' {
            Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should have Medium ConfirmImpact' {
            $cmd = Get-Command Update-ZoomUserStatus
            $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] } |
                Select-Object -ExpandProperty ConfirmImpact | Should -Be 'Medium'
        }
    }

    Context 'Return value behavior' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success'; message = 'User status updated' }
            }
        }

        It 'Should return API response by default' {
            $result = Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false
            $result.status | Should -Be 'success'
        }

        It 'Should return UserId array when Passthru is specified' {
            $result = Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -PassThru -Confirm:$false
            $result | Should -Contain 'user@example.com'
        }

        It 'Should not return API response when Passthru is specified' {
            $result = Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -PassThru -Confirm:$false
            $result | Should -Contain 'user@example.com'
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should return UserIds array when processing multiple users with Passthru' {
            $results = @('user1@example.com', 'user2@example.com') | Update-ZoomUserStatus -Action 'activate' -PassThru -Confirm:$false
            $results | Should -Contain 'user1@example.com'
            $results | Should -Contain 'user2@example.com'
        }

        It 'Should return array of responses when processing multiple users without Passthru' {
            $results = @('user1@example.com', 'user2@example.com') | Update-ZoomUserStatus -Action 'activate' -Confirm:$false
            @($results).Count | Should -Be 2
            $results[0].status | Should -Be 'success'
            $results[1].status | Should -Be 'success'
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept Email alias for UserId' {
            { Update-ZoomUserStatus -Email 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Emails alias for UserId' {
            { Update-ZoomUserStatus -Emails 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Update-ZoomUserStatus -EmailAddress 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept EmailAddresses alias for UserId' {
            { Update-ZoomUserStatus -EmailAddresses 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Update-ZoomUserStatus -Id 'user123' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept ids alias for UserId' {
            { Update-ZoomUserStatus -ids 'user123' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept user_id alias for UserId' {
            { Update-ZoomUserStatus -user_id 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept user alias for UserId' {
            { Update-ZoomUserStatus -user 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept users alias for UserId' {
            { Update-ZoomUserStatus -users 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept userids alias for UserId' {
            { Update-ZoomUserStatus -userids 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Required parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should require UserId parameter' {
            { Update-ZoomUserStatus -Action 'activate' -Confirm:$false } | Should -Throw
        }

        It 'Should require Action parameter' {
            { Update-ZoomUserStatus -UserId 'user@example.com' -Confirm:$false } | Should -Throw
        }

        It 'Should accept both required parameters' {
            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId as first positional parameter' {
            { Update-ZoomUserStatus 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept Action as second positional parameter' {
            { Update-ZoomUserStatus 'user@example.com' 'activate' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Multiple users processing' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should process each user separately' {
            Update-ZoomUserStatus -UserId @('user1@example.com', 'user2@example.com', 'user3@example.com') -Action 'activate' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should call correct endpoint for each user' {
            $callCount = 0
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $Uri.ToString() | Should -Match 'users/user1@example.com/status'
                }
                if ($script:callCount -eq 2) {
                    $Uri.ToString() | Should -Match 'users/user2@example.com/status'
                }
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId @('user1@example.com', 'user2@example.com') -Action 'activate' -Confirm:$false
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
                $bodyObj.PSObject.Properties.Name | Should -Contain 'action'
                $bodyObj.PSObject.Properties.Count | Should -Be 1
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false
        }

        It 'Should send valid JSON' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                { $Body | ConvertFrom-Json } | Should -Not -Throw
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Update-ZoomUserStatus -UserId 'nonexistent@example.com' -Action 'activate' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle permission errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Insufficient privileges')
            }

            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle invalid status transition errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Invalid status transition')
            }

            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Network error')
            }

            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'UserId length validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId within valid length' {
            { Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject UserId exceeding 128 characters' {
            $longUserId = 'a' * 129
            { Update-ZoomUserStatus -UserId $longUserId -Action 'activate' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Different user ID formats' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept email address as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'users/user@example.com/status'
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId 'user@example.com' -Action 'activate' -Confirm:$false
        }

        It 'Should accept user ID string as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'users/abc123xyz/status'
                return @{ status = 'success' }
            }

            Update-ZoomUserStatus -UserId 'abc123xyz' -Action 'activate' -Confirm:$false
        }
    }
}
