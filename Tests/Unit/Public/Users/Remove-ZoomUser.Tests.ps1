BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Remove-ZoomUser' {
    Context 'When removing a user with default action (disassociate)' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser@example.com'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should call API with correct endpoint and action' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'users/testuser@example.com'
                $Uri.ToString() | Should -Match 'action=disassociate'
                $Method | Should -Be 'DELETE'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should call Get-ZoomUser to check user status' {
            Remove-ZoomUser -UserId 'testuser@example.com' -Confirm:$false
            Should -Invoke Get-ZoomUser -ModuleName PSZoom -Times 1
        }
    }

    Context 'When removing a user with delete action' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser@example.com'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should call API with delete action' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.ToString() | Should -Match 'action=delete'
                $Method | Should -Be 'DELETE'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser@example.com' -Action 'delete' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'When removing a pending user' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'pendinguser@example.com'
                    status = 'pending'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should not add query parameters for pending users' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri, $Method)
                $Uri.Query | Should -BeNullOrEmpty
                return $null
            }

            Remove-ZoomUser -UserId 'pendinguser@example.com' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Transfer parameters' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser@example.com'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should include TransferEmail in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'transfer_email=admin%40example\.com'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser@example.com' -TransferEmail 'admin@example.com' -Confirm:$false
        }

        It 'Should include TransferMeeting in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'transfer_meeting=true'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser@example.com' -TransferMeeting -Confirm:$false
        }

        It 'Should include TransferWebinar in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'transfer_webinar=true'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser@example.com' -TransferWebinar -Confirm:$false
        }

        It 'Should include TransferRecording in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'transfer_recording=true'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser@example.com' -TransferRecording -Confirm:$false
        }

        It 'Should include TransferWhiteboard in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'transfer_whiteboard=true'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser@example.com' -TransferWhiteboard -Confirm:$false
        }

        It 'Should include multiple transfer parameters' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'transfer_email=admin%40example\.com'
                $Uri.ToString() | Should -Match 'transfer_meeting=true'
                $Uri.ToString() | Should -Match 'transfer_recording=true'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser@example.com' -TransferEmail 'admin@example.com' -TransferMeeting -TransferRecording -Confirm:$false
        }
    }

    Context 'EncryptedEmail parameter' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should include encrypted_email in query string' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match 'encrypted_email=true'
                return $null
            }

            Remove-ZoomUser -UserId 'testuser' -EncryptedEmail -Confirm:$false
        }
    }

    Context 'Action parameter validation' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser@example.com'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept disassociate action' {
            { Remove-ZoomUser -UserId 'testuser@example.com' -Action 'disassociate' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept delete action' {
            { Remove-ZoomUser -UserId 'testuser@example.com' -Action 'delete' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should reject invalid action values' {
            { Remove-ZoomUser -UserId 'testuser@example.com' -Action 'invalid' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser@example.com'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept UserId from pipeline' {
            'user@example.com' | Remove-ZoomUser -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should process multiple UserIds from pipeline' {
            @('user1@example.com', 'user2@example.com') | Remove-ZoomUser -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'SupportsShouldProcess behavior' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser@example.com'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should support WhatIf parameter' {
            Remove-ZoomUser -UserId 'user@example.com' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should have Medium ConfirmImpact' {
            $cmd = Get-Command Remove-ZoomUser
            $cmd.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] } |
                Select-Object -ExpandProperty ConfirmImpact | Should -Be 'Medium'
        }
    }

    Context 'Passthru parameter' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser@example.com'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should return UserId when Passthru is specified' {
            $result = Remove-ZoomUser -UserId 'user@example.com' -Passthru -Confirm:$false
            $result | Should -Be 'user@example.com'
        }

        It 'Should return API response when Passthru is not specified' {
            $result = Remove-ZoomUser -UserId 'user@example.com' -Confirm:$false
            # Should invoke and return the mock result
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomUser -ModuleName PSZoom {
                return @{
                    id = 'testuser@example.com'
                    status = 'active'
                }
            }
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return $null
            }
        }

        It 'Should accept Email alias for UserId' {
            { Remove-ZoomUser -Email 'user@example.com' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept id alias for UserId' {
            { Remove-ZoomUser -id 'user123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept encrypted_email alias' {
            { Remove-ZoomUser -UserId 'user@example.com' -encrypted_email -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept transfer_email alias' {
            { Remove-ZoomUser -UserId 'user@example.com' -transfer_email 'admin@example.com' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept transfer_meeting alias' {
            { Remove-ZoomUser -UserId 'user@example.com' -transfer_meeting -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept transfer_webinar alias' {
            { Remove-ZoomUser -UserId 'user@example.com' -transfer_webinar -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept transfer_recording alias' {
            { Remove-ZoomUser -UserId 'user@example.com' -transfer_recording -Confirm:$false } | Should -Not -Throw
        }

        It 'Should accept transfer_whiteboard alias' {
            { Remove-ZoomUser -UserId 'user@example.com' -transfer_whiteboard -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomUser -ModuleName PSZoom {
                throw [System.Net.WebException]::new('User not found')
            }

            { Remove-ZoomUser -UserId 'nonexistent@example.com' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle Get-ZoomUser errors with ErrorAction Stop' {
            Mock Get-ZoomUser -ModuleName PSZoom {
                throw 'User retrieval failed'
            }

            { Remove-ZoomUser -UserId 'user@example.com' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
