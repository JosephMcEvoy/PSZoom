BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }

    # Create a temporary test image file
    $script:TestImagePath = Join-Path $env:TEMP 'test-profile-picture.jpg'
    if (-not (Test-Path $script:TestImagePath)) {
        # Create a simple test file with binary content
        [byte[]]$bytes = [System.Text.Encoding]::UTF8.GetBytes('fake image content')
        [System.IO.File]::WriteAllBytes($script:TestImagePath, $bytes)
    }
}

AfterAll {
    # Clean up test file
    if (Test-Path $script:TestImagePath) {
        Remove-Item -Path $script:TestImagePath -Force
    }
}

Describe 'Update-ZoomProfilePicture' {
    Context 'When uploading a profile picture' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com/picture'
                $Method | Should -Be 'POST'
                return @{ status = 'success' }
            }

            Update-ZoomProfilePicture -UserId 'testuser@example.com' -FileName $script:TestImagePath
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use multipart/form-data content type' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($ContentType)
                $ContentType | Should -Match 'multipart/form-data'
                return @{ status = 'success' }
            }

            Update-ZoomProfilePicture -UserId 'testuser@example.com' -FileName $script:TestImagePath
        }

        It 'Should include boundary in content type' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($ContentType)
                $ContentType | Should -Match 'boundary='
                return @{ status = 'success' }
            }

            Update-ZoomProfilePicture -UserId 'testuser@example.com' -FileName $script:TestImagePath
        }

        It 'Should include request body' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Body)
                $Body | Should -Not -BeNullOrEmpty
                return @{ status = 'success' }
            }

            Update-ZoomProfilePicture -UserId 'testuser@example.com' -FileName $script:TestImagePath
        }
    }

    Context 'File validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should validate that file exists' {
            { Update-ZoomProfilePicture -UserId 'user@example.com' -FileName 'C:\nonexistent\file.jpg' } | Should -Throw
        }

        It 'Should accept valid file path' {
            { Update-ZoomProfilePicture -UserId 'user@example.com' -FileName $script:TestImagePath } | Should -Not -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Update-ZoomProfilePicture -FileName $script:TestImagePath
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            @('user1@example.com', 'user2@example.com') | Update-ZoomProfilePicture -FileName $script:TestImagePath
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'user@example.com' }
            $userObject | Update-ZoomProfilePicture -FileName $script:TestImagePath
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Return value behavior' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success'; message = 'Profile picture updated' }
            }
        }

        It 'Should return API response' {
            $result = Update-ZoomProfilePicture -UserId 'user@example.com' -FileName $script:TestImagePath
            $result.status | Should -Be 'success'
            $result.message | Should -Be 'Profile picture updated'
        }

        It 'Should return response for each user when processing multiple users' {
            $results = @('user1@example.com', 'user2@example.com') | Update-ZoomProfilePicture -FileName $script:TestImagePath
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
            { Update-ZoomProfilePicture -Email 'user@example.com' -FileName $script:TestImagePath } | Should -Not -Throw
        }

        It 'Should accept EmailAddress alias for UserId' {
            { Update-ZoomProfilePicture -EmailAddress 'user@example.com' -FileName $script:TestImagePath } | Should -Not -Throw
        }

        It 'Should accept Id alias for UserId' {
            { Update-ZoomProfilePicture -Id 'user123' -FileName $script:TestImagePath } | Should -Not -Throw
        }
    }

    Context 'Multiple users processing' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should process each user separately' {
            Update-ZoomProfilePicture -UserId @('user1@example.com', 'user2@example.com', 'user3@example.com') -FileName $script:TestImagePath
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3
        }

        It 'Should call correct endpoint for each user' {
            $callCount = 0
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $script:callCount++
                if ($script:callCount -eq 1) {
                    $Uri.ToString() | Should -Match 'users/user1@example.com/picture'
                }
                if ($script:callCount -eq 2) {
                    $Uri.ToString() | Should -Match 'users/user2@example.com/picture'
                }
                return @{ status = 'success' }
            }

            Update-ZoomProfilePicture -UserId @('user1@example.com', 'user2@example.com') -FileName $script:TestImagePath
        }
    }

    Context 'PowerShell version compatibility' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should handle file reading based on PowerShell version' {
            # This test verifies the cmdlet runs without error
            # The actual file reading logic changes based on PS version
            { Update-ZoomProfilePicture -UserId 'user@example.com' -FileName $script:TestImagePath } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Update-ZoomProfilePicture -UserId 'nonexistent@example.com' -FileName $script:TestImagePath -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle file not found errors' {
            { Update-ZoomProfilePicture -UserId 'user@example.com' -FileName 'C:\nonexistent\picture.jpg' -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle upload errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Exception]::new('Upload failed')
            }

            { Update-ZoomProfilePicture -UserId 'user@example.com' -FileName $script:TestImagePath -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'CmdletBinding attributes' {
        It 'Should not have SupportsShouldProcess' {
            $cmd = Get-Command Update-ZoomProfilePicture
            $attributes = $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $attributes.SupportsShouldProcess | Should -Not -Be $true
        }
    }

    Context 'Parameter validation' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{ status = 'success' }
            }
        }

        It 'Should require UserId parameter' {
            { Update-ZoomProfilePicture -FileName $script:TestImagePath } | Should -Throw
        }

        It 'Should require FileName parameter' {
            { Update-ZoomProfilePicture -UserId 'user@example.com' } | Should -Throw
        }

        It 'Should accept both required parameters' {
            { Update-ZoomProfilePicture -UserId 'user@example.com' -FileName $script:TestImagePath } | Should -Not -Throw
        }
    }
}
