<#
.SYNOPSIS
    Integration tests for Zoom Users API.

.DESCRIPTION
    These tests make actual API calls to Zoom and require valid credentials.
    They are tagged with 'Integration' and excluded from the default test run.

    To run integration tests:
    1. Set environment variables: ZOOM_ACCOUNT_ID, ZOOM_CLIENT_ID, ZOOM_CLIENT_SECRET
    2. Run: Invoke-Pester -Path './Tests/Integration' -Tag 'Integration'

.NOTES
    These tests require a valid Zoom account with API access.
    Be careful not to modify production data when running these tests.
#>

BeforeAll {
    # Import the main module
    $ModulePath = "$PSScriptRoot/../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    # Import the test helper
    Import-Module "$PSScriptRoot/../Helpers/ZoomTestHelper.psm1" -Force
}

Describe 'Get-ZoomUsers Integration Tests' -Tag 'Integration' {
    BeforeAll {
        # Skip all tests in this describe block if credentials are not available
        if (-not (Test-ZoomCredentialsAvailable)) {
            $script:SkipTests = $true
        } else {
            $script:SkipTests = $false
            Connect-ZoomTestAccount
        }
    }

    Context 'When retrieving users from live API' {
        It 'Should return users from the account' {
            if ($script:SkipTests) {
                Set-ItResult -Skipped -Because (Get-ZoomTestSkipReason)
                return
            }

            $result = Get-ZoomUsers -PageSize 10

            $result | Should -Not -BeNullOrEmpty
            # API should return some kind of response, even if no users
        }

        It 'Should return user details when specifying a valid user' {
            if ($script:SkipTests) {
                Set-ItResult -Skipped -Because (Get-ZoomTestSkipReason)
                return
            }

            # First get a list of users to get a valid user ID
            $users = Get-ZoomUsers -PageSize 1

            if ($users.users -and $users.users.Count -gt 0) {
                $userId = $users.users[0].id
                $result = Get-ZoomUser -UserId $userId

                $result | Should -Not -BeNullOrEmpty
                $result.id | Should -Be $userId
            } else {
                Set-ItResult -Skipped -Because 'No users available in the account'
            }
        }
    }
}

