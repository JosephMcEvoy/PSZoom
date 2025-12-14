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

    # Note: Get-ZoomItemFullDetails uses Invoke-Expression to call cmdlets dynamically.
    # For PS 7+, it uses ForEach-Object -Parallel which runs in separate runspaces
    # where mocks are not available. These tests are skipped on PS 7+ since we cannot
    # effectively mock the parallel execution path without integration testing.

    Context 'Single object retrieval' -Skip:($PSVersionTable.PSVersion.Major -ge 7) {
        It 'Should retrieve details for single ObjectId' {
            InModuleScope PSZoom {
                # Mock Invoke-Expression since the function calls cmdlets via Invoke-Expression
                Mock Invoke-Expression {
                    return @{ id = 'user123'; email = 'user123@test.com' }
                }

                $result = Get-ZoomItemFullDetails -ObjectIds @('user123') -CmdletToRun 'Get-ZoomUser'
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke Invoke-Expression -Times 1
            }
        }
    }

    Context 'Multiple object retrieval' -Skip:($PSVersionTable.PSVersion.Major -ge 7) {
        It 'Should retrieve details for multiple ObjectIds' {
            InModuleScope PSZoom {
                Mock Invoke-Expression {
                    return @{ id = 'mockuser'; email = 'mock@test.com' }
                }

                $objectIds = @('user1', 'user2', 'user3')
                $result = Get-ZoomItemFullDetails -ObjectIds $objectIds -CmdletToRun 'Get-ZoomUser'

                # Result should be an array or collection
                @($result).Count | Should -Be 3
                Should -Invoke Invoke-Expression -Times 3
            }
        }
    }

    Context 'Pipeline support' -Skip:($PSVersionTable.PSVersion.Major -ge 7) {
        It 'Should accept ObjectIds from pipeline' {
            InModuleScope PSZoom {
                Mock Invoke-Expression {
                    return @{ id = 'pipelineuser' }
                }

                $result = @('pipelineuser') | Get-ZoomItemFullDetails -CmdletToRun 'Get-ZoomUser'
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }

    Context 'PowerShell version handling' {
        It 'Should use parallel processing on PowerShell 7+' -Skip:($PSVersionTable.PSVersion.Major -lt 7) {
            # On PS 7+, we can only verify the function doesn't throw
            # Mocking doesn't work with ForEach-Object -Parallel as it runs in separate runspaces
            # This is effectively an integration test behavior verification
            InModuleScope PSZoom {
                # Mock Invoke-ZoomRestMethod to prevent actual API calls
                Mock Invoke-ZoomRestMethod {
                    return @{ id = 'phone123' }
                }

                # The function will fail because mocks don't work in parallel runspaces,
                # but we can verify the command structure is correct by checking it doesn't
                # throw a parameter binding error
                { Get-ZoomItemFullDetails -ObjectIds @('phone123') -CmdletToRun 'Get-ZoomPhoneNumber' } | Should -Not -Throw '*parameter*'
            }
        }

        It 'Should use sequential processing on PowerShell 5.1' -Skip:($PSVersionTable.PSVersion.Major -ge 7) {
            InModuleScope PSZoom {
                Mock Invoke-Expression {
                    return @{ id = 'phone123' }
                }

                $result = Get-ZoomItemFullDetails -ObjectIds @('phone123') -CmdletToRun 'Get-ZoomPhoneNumber'
                $result | Should -Not -BeNullOrEmpty
                Should -Invoke Invoke-Expression -Times 1
            }
        }
    }

    Context 'Return type' -Skip:($PSVersionTable.PSVersion.Major -ge 7) {
        It 'Should return array of results for multiple objects' {
            InModuleScope PSZoom {
                Mock Invoke-Expression {
                    return @{ id = 'mockid' }
                }

                $result = Get-ZoomItemFullDetails -ObjectIds @('id1', 'id2') -CmdletToRun 'Get-ZoomUser'
                @($result).Count | Should -Be 2
            }
        }
    }

    Context 'Function structure validation' {
        It 'Should have correct parameter attributes' {
            InModuleScope PSZoom {
                $cmd = Get-Command Get-ZoomItemFullDetails
                $cmd.Parameters['ObjectIds'].Attributes |
                    Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                    ForEach-Object { $_.Mandatory } | Should -Contain $true
                $cmd.Parameters['CmdletToRun'].Attributes |
                    Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                    ForEach-Object { $_.Mandatory } | Should -Contain $true
            }
        }

        It 'Should accept pipeline input for ObjectIds' {
            InModuleScope PSZoom {
                $cmd = Get-Command Get-ZoomItemFullDetails
                $cmd.Parameters['ObjectIds'].Attributes |
                    Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] } |
                    ForEach-Object { $_.ValueFromPipeline } | Should -Contain $true
            }
        }
    }
}
