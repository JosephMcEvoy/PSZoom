BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Add-ZoomDivisionMember' {
    Context 'When adding members to a division' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            Add-ZoomDivisionMember -DivisionId 'div123' -UserIds 'user456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -like 'https://api.zoom.us/v2/divisions/div123/users*'
            }
        }

        It 'Should use POST method' {
            Add-ZoomDivisionMember -DivisionId 'div123' -UserIds 'user456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should include user_ids in body for single user' {
            Add-ZoomDivisionMember -DivisionId 'div123' -UserIds 'user456'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.user_ids -contains 'user456'
            }
        }

        It 'Should include multiple user_ids in body' {
            Add-ZoomDivisionMember -DivisionId 'div123' -UserIds @('user1', 'user2', 'user3')
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.user_ids.Count -eq 3 -and
                $Body.user_ids -contains 'user1' -and
                $Body.user_ids -contains 'user2' -and
                $Body.user_ids -contains 'user3'
            }
        }

        It 'Should return true on success' {
            $result = Add-ZoomDivisionMember -DivisionId 'div123' -UserIds 'user456'
            $result | Should -Be $true
        }
    }

    Context 'Pipeline Support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $null }
        }

        It 'Should accept pipeline input by property name' {
            [PSCustomObject]@{ DivisionId = 'div123'; UserIds = @('user456') } | Add-ZoomDivisionMember
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }
}
