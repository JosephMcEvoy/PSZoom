BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Set up required module state
    $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
    $script:ZoomURI = 'zoom.us'

    # Load mock response fixtures
    $script:MockUserGet = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/user-get.json" | ConvertFrom-Json
    $script:MockUserList = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/user-list.json" | ConvertFrom-Json
}

Describe 'Get-ZoomUser' {
    Context 'When retrieving a single user by UserId' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserGet
            }
        }

        It 'Should return user details' {
            $result = Get-ZoomUser -UserId 'KDcuGIm1QgePTO8WbOqwIQ'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return user with correct email' {
            $result = Get-ZoomUser -UserId 'KDcuGIm1QgePTO8WbOqwIQ'
            $result.email | Should -Be 'jane.doe@example.com'
        }

        It 'Should return user with correct id' {
            $result = Get-ZoomUser -UserId 'KDcuGIm1QgePTO8WbOqwIQ'
            $result.id | Should -Be 'KDcuGIm1QgePTO8WbOqwIQ'
        }

        It 'Should call API with correct endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'users/testuser123'
                return $script:MockUserGet
            }

            Get-ZoomUser -UserId 'testuser123'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'When retrieving users by email' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserGet
            }
        }

        It 'Should accept email as UserId' {
            $result = Get-ZoomUser -UserId 'jane.doe@example.com'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserGet
            }
        }

        It 'Should accept UserId from pipeline' {
            $result = 'KDcuGIm1QgePTO8WbOqwIQ' | Get-ZoomUser
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept multiple UserIds from pipeline' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserGet
            }

            $results = @('user1', 'user2') | Get-ZoomUser
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept object with id property from pipeline' {
            $userObject = [PSCustomObject]@{ id = 'KDcuGIm1QgePTO8WbOqwIQ' }
            $result = $userObject | Get-ZoomUser
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'When listing all users' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserList
            }
        }

        It 'Should return list of users using Get-ZoomUsers alias' {
            $result = Get-ZoomUsers
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple users' {
            $result = Get-ZoomUsers
            @($result).Count | Should -BeGreaterOrEqual 1
        }
    }

    Context 'Status filter parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserList
            }
        }

        It 'Should accept active status' {
            { Get-ZoomUser -Status 'active' } | Should -Not -Throw
        }

        It 'Should accept inactive status' {
            { Get-ZoomUser -Status 'inactive' } | Should -Not -Throw
        }

        It 'Should accept pending status' {
            { Get-ZoomUser -Status 'pending' } | Should -Not -Throw
        }

        It 'Should reject invalid status values' {
            { Get-ZoomUser -Status 'invalid' } | Should -Throw
        }
    }

    Context 'LoginType parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserGet
            }
        }

        It 'Should accept numeric LoginType' {
            { Get-ZoomUser -UserId 'test@test.com' -LoginType 100 } | Should -Not -Throw
        }

        It 'Should reject invalid LoginType values' {
            { Get-ZoomUser -UserId 'test@test.com' -LoginType 999 } | Should -Throw
        }
    }

    Context 'Pagination parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserList
            }
        }

        It 'Should accept PageSize parameter' {
            { Get-ZoomUser -PageSize 50 -NextPageToken 'token123' } | Should -Not -Throw
        }

        It 'Should validate PageSize range (1-100)' {
            { Get-ZoomUser -PageSize 0 -NextPageToken 'token' } | Should -Throw
            { Get-ZoomUser -PageSize 101 -NextPageToken 'token' } | Should -Throw
        }

        It 'Should accept NextPageToken parameter' {
            { Get-ZoomUser -NextPageToken 'abc123token' -PageSize 30 } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserGet
            }
        }

        It 'Should accept User_Id alias for UserId' {
            { Get-ZoomUser -User_Id 'testuser' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomUser -page_size 50 -next_page_token 'token' } | Should -Not -Throw
        }
    }

    Context 'Full parameter' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $script:MockUserList
            }
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @($script:MockUserGet)
            }
        }

        It 'Should accept Full switch parameter' {
            { Get-ZoomUser -Full } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Get-ZoomUser -UserId 'nonexistent' -ErrorAction Stop } | Should -Throw
        }
    }
}
