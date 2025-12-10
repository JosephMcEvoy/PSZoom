BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Update-ZoomUserEmail' {
    Context 'When updating a user email' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/olduser@example.com/email'
                $Method | Should -Be 'PUT'
                return $null
            }

            Update-ZoomUserEmail -UserId 'olduser@example.com' -Email 'newuser@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should include email in request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.email | Should -Be 'newuser@example.com'
                return $null
            }

            Update-ZoomUserEmail -UserId 'olduser@example.com' -Email 'newuser@example.com'
        }

        It 'Should send request body as JSON' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                { $Body | ConvertFrom-Json } | Should -Not -Throw
                return $null
            }

            Update-ZoomUserEmail -UserId 'olduser@example.com' -Email 'newuser@example.com'
        }
    }

    Context 'Email parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept email within valid length' {
            { Update-ZoomUserEmail -UserId 'user@example.com' -Email 'newuser@example.com' } | Should -Not -Throw
        }

        It 'Should reject email exceeding 128 characters' {
            $longEmail = ('a' * 120) + '@test.com'
            { Update-ZoomUserEmail -UserId 'user@example.com' -Email $longEmail } | Should -Throw
        }

        It 'Should accept email at maximum length (128 characters)' {
            $maxEmail = ('a' * 110) + '@example.com'
            { Update-ZoomUserEmail -UserId 'user@example.com' -Email $maxEmail } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Update-ZoomUserEmail -Email 'newuser@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should not accept multiple UserIds from pipeline' {
            # This cmdlet processes one user at a time (no array in param)
            'user@example.com' | Update-ZoomUserEmail -Email 'newuser@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user@example.com' }
            $userObject | Update-ZoomUserEmail -Email 'newuser@example.com'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should return UserId array when Passthru is specified' {
            $result = Update-ZoomUserEmail -UserId 'user@example.com' -Email 'newuser@example.com' -Passthru
            $result | Should -Contain 'user@example.com'
        }

        It 'Should not return output when Passthru is not specified' {
            $result = Update-ZoomUserEmail -UserId 'user@example.com' -Email 'newuser@example.com'
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept Id alias for UserId' {
            { Update-ZoomUserEmail -Id 'user@example.com' -Email 'newuser@example.com' } | Should -Not -Throw
        }
    }

    Context 'Required parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should require UserId parameter' {
            { Update-ZoomUserEmail -Email 'newuser@example.com' } | Should -Throw
        }

        It 'Should require Email parameter' {
            { Update-ZoomUserEmail -UserId 'user@example.com' } | Should -Throw
        }

        It 'Should accept both required parameters' {
            { Update-ZoomUserEmail -UserId 'user@example.com' -Email 'newuser@example.com' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept UserId as first positional parameter' {
            { Update-ZoomUserEmail 'user@example.com' -Email 'newuser@example.com' } | Should -Not -Throw
        }

        It 'Should accept Email as second positional parameter' {
            { Update-ZoomUserEmail 'user@example.com' 'newuser@example.com' } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Update-ZoomUserEmail -UserId 'nonexistent@example.com' -Email 'newuser@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle email already exists errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Email address already exists')
            }

            { Update-ZoomUserEmail -UserId 'user@example.com' -Email 'existing@example.com' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle invalid email format errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Invalid email address')
            }

            { Update-ZoomUserEmail -UserId 'user@example.com' -Email 'invalid-email' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'CmdletBinding attributes' {
        It 'Should not have SupportsShouldProcess' {
            $cmd = Get-Command Update-ZoomUserEmail
            $attributes = $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $attributes.SupportsShouldProcess | Should -Not -Be $true
        }
    }

    Context 'Request body structure' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should create proper JSON structure' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $bodyObj = $Body | ConvertFrom-Json
                $bodyObj.PSObject.Properties.Name | Should -Contain 'email'
                $bodyObj.PSObject.Properties.Count | Should -Be 1
                return $null
            }

            Update-ZoomUserEmail -UserId 'user@example.com' -Email 'newuser@example.com'
        }
    }

    Context 'Different user ID formats' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept email address as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'users/olduser@example.com/email'
                return $null
            }

            Update-ZoomUserEmail -UserId 'olduser@example.com' -Email 'newuser@example.com'
        }

        It 'Should accept user ID string as UserId' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'users/abc123xyz/email'
                return $null
            }

            Update-ZoomUserEmail -UserId 'abc123xyz' -Email 'newuser@example.com'
        }
    }
}
