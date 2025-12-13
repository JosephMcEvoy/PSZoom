BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $script:MockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-registrant-delete.json" -Raw | ConvertFrom-Json
}

Describe 'Remove-ZoomWebinarRegistrant' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns expected response when removing a registrant' {
            $result = Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abcdef123456' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abcdef123456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URI with required parameters' {
            Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abcdef123456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/123456789/registrants/abcdef123456*'
            }
        }

        It 'Uses DELETE method' {
            Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abcdef123456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Includes occurrence_id as query parameter when specified' {
            Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abcdef123456' -OccurrenceId '1648538400000' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*occurrence_id=1648538400000*'
            }
        }

        It 'Does not include occurrence_id query parameter when not specified' {
            Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abcdef123456' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -notlike '*occurrence_id*'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Requires RegistrantId parameter' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['RegistrantId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'OccurrenceId parameter is optional' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['OccurrenceId'].Attributes.Mandatory | Should -Contain $false
        }

        It 'WebinarId accepts alias webinar_id' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'WebinarId accepts alias Id' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['WebinarId'].Aliases | Should -Contain 'Id'
        }

        It 'RegistrantId accepts alias registrant_id' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['RegistrantId'].Aliases | Should -Contain 'registrant_id'
        }

        It 'OccurrenceId accepts alias occurrence_id' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['OccurrenceId'].Aliases | Should -Contain 'occurrence_id'
        }

        It 'WebinarId is of type int64' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }

        It 'RegistrantId is of type string' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters['RegistrantId'].ParameterType.Name | Should -Be 'String'
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by property name' {
            $input = [PSCustomObject]@{ WebinarId = 123456789; RegistrantId = 'abcdef123456' }
            $input | Remove-ZoomWebinarRegistrant -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts RegistrantId from pipeline by property name' {
            $input = [PSCustomObject]@{ RegistrantId = 'abcdef123456' }
            $input | Remove-ZoomWebinarRegistrant -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*registrants/abcdef123456*'
            }
        }

        It 'Accepts RegistrantId directly from pipeline' {
            'abcdef123456' | Remove-ZoomWebinarRegistrant -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*registrants/abcdef123456*'
            }
        }

        It 'Processes multiple pipeline objects' {
            $registrants = @(
                [PSCustomObject]@{ RegistrantId = 'registrant1' },
                [PSCustomObject]@{ RegistrantId = 'registrant2' },
                [PSCustomObject]@{ RegistrantId = 'registrant3' }
            )
            $registrants | Remove-ZoomWebinarRegistrant -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3 -Exactly
        }

        It 'Accepts OccurrenceId from pipeline by property name' {
            $input = [PSCustomObject]@{ WebinarId = 123456789; RegistrantId = 'abcdef123456'; OccurrenceId = '1648538400000' }
            $input | Remove-ZoomWebinarRegistrant -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*occurrence_id=1648538400000*'
            }
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters.ContainsKey('WhatIf') | Should -Be $true
        }

        It 'Supports Confirm parameter' {
            (Get-Command Remove-ZoomWebinarRegistrant).Parameters.ContainsKey('Confirm') | Should -Be $true
        }

        It 'Does not call API when WhatIf is specified' {
            Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'abcdef123456' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0 -Exactly
        }

        It 'Has Medium ConfirmImpact' {
            $cmdletAttribute = (Get-Command Remove-ZoomWebinarRegistrant).ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletAttribute.ConfirmImpact | Should -Be 'Medium'
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error: Registrant not found' }
        }

        It 'Throws an error when API call fails' {
            { Remove-ZoomWebinarRegistrant -WebinarId 123456789 -RegistrantId 'invalid' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
