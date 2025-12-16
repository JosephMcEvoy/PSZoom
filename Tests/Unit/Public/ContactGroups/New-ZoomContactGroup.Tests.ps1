BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'New-ZoomContactGroup' {
    Context 'When creating a contact group' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    group_id      = 'grp123'
                    group_name    = 'New Team'
                    total_members = 0
                    group_privacy = 2
                }
            }
        }

        It 'Should call Invoke-ZoomRestMethod with correct URI' {
            New-ZoomContactGroup -GroupName 'New Team' -GroupPrivacy 2
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Uri -eq 'https://api.zoom.us/v2/contacts/groups'
            }
        }

        It 'Should use POST method' {
            New-ZoomContactGroup -GroupName 'New Team' -GroupPrivacy 2
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Method -eq 'Post'
            }
        }

        It 'Should include required parameters in body' {
            New-ZoomContactGroup -GroupName 'New Team' -GroupPrivacy 2
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.group_name -eq 'New Team' -and $Body.group_privacy -eq 2
            }
        }

        It 'Should include description when specified' {
            New-ZoomContactGroup -GroupName 'New Team' -GroupPrivacy 2 -Description 'Test description'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.description -eq 'Test description'
            }
        }

        It 'Should include group members when specified' {
            $members = @(@{ type = 1; id = 'user123' })
            New-ZoomContactGroup -GroupName 'New Team' -GroupPrivacy 2 -GroupMembers $members
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -ParameterFilter {
                $Body.group_members -ne $null
            }
        }

        It 'Should return created group' {
            $result = New-ZoomContactGroup -GroupName 'New Team' -GroupPrivacy 2
            $result.group_id | Should -Be 'grp123'
        }
    }
}
