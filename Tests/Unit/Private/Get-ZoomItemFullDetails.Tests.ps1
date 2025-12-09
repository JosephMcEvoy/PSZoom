BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Get-ZoomItemFullDetails' {
    BeforeAll {
        # Set up required module state within module scope
        InModuleScope PSZoom {
            $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
            $script:ZoomURI = 'zoom.us'
        }
    }

    Context 'Parameter validation' {
        It 'Should require ObjectIds parameter' {
            InModuleScope PSZoom {
                { Get-ZoomItemFullDetails -CmdletToRun 'Get-ZoomUser' } | Should -Throw
            }
        }

        It 'Should require CmdletToRun parameter' {
            InModuleScope PSZoom {
                { Get-ZoomItemFullDetails -ObjectIds @('id1') } | Should -Throw
            }
        }
    }

    Context 'Single object retrieval' {
        It 'Should retrieve details for single ObjectId' {
            InModuleScope PSZoom {
                # Mock the cmdlet that will be invoked
                Mock Get-ZoomUser {
                    param($UserId)
                    return @{
                        id = $UserId
                        email = "$UserId@test.com"
                        first_name = 'Test'
                        last_name = 'User'
                    }
                }

                # For PS 5.1 compatibility, we need to test the sequential path
                if ($PSVersionTable.PSVersion.Major -lt 7) {
                    Mock Invoke-Expression {
                        return @{ id = 'user123'; email = 'user123@test.com' }
                    }
                }

                $result = Get-ZoomItemFullDetails -ObjectIds @('user123') -CmdletToRun 'Get-ZoomUser'
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Multiple object retrieval' {
        It 'Should retrieve details for multiple ObjectIds' {
            InModuleScope PSZoom {
                if ($PSVersionTable.PSVersion.Major -lt 7) {
                    Mock Invoke-Expression {
                        return @{ id = 'mockuser'; email = 'mock@test.com' }
                    }
                }

                $objectIds = @('user1', 'user2', 'user3')
                $result = Get-ZoomItemFullDetails -ObjectIds $objectIds -CmdletToRun 'Get-ZoomUser'

                # Result should be an array or collection
                @($result).Count | Should -BeGreaterOrEqual 1
            }
        }
    }

    Context 'Pipeline support' {
        It 'Should accept ObjectIds from pipeline' {
            InModuleScope PSZoom {
                if ($PSVersionTable.PSVersion.Major -lt 7) {
                    Mock Invoke-Expression {
                        return @{ id = 'pipelineuser' }
                    }
                }

                $result = @('pipelineuser') | Get-ZoomItemFullDetails -CmdletToRun 'Get-ZoomUser'
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'PowerShell version handling' {
        It 'Should handle PowerShell 7+ with parallel processing' -Skip:($PSVersionTable.PSVersion.Major -lt 7) {
            InModuleScope PSZoom {
                # This test only runs on PS 7+
                Mock Get-ZoomPhoneNumber {
                    return @{ id = 'phone123' }
                }

                $result = Get-ZoomItemFullDetails -ObjectIds @('phone123') -CmdletToRun 'Get-ZoomPhoneNumber'
                $result | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should handle PowerShell 5.1 with sequential processing' -Skip:($PSVersionTable.PSVersion.Major -ge 7) {
            InModuleScope PSZoom {
                # This test only runs on PS 5.1
                Mock Invoke-Expression {
                    return @{ id = 'phone123' }
                }

                $result = Get-ZoomItemFullDetails -ObjectIds @('phone123') -CmdletToRun 'Get-ZoomPhoneNumber'
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'Return type' {
        It 'Should return array of results for multiple objects' {
            InModuleScope PSZoom {
                if ($PSVersionTable.PSVersion.Major -lt 7) {
                    Mock Invoke-Expression {
                        return @{ id = 'mockid' }
                    }
                }

                $result = Get-ZoomItemFullDetails -ObjectIds @('id1', 'id2') -CmdletToRun 'Get-ZoomUser'
                @($result).Count | Should -BeGreaterOrEqual 1
            }
        }
    }
}
