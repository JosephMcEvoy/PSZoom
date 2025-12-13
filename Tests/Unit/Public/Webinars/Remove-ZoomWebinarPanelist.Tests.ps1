BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $script:MockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/w-e-b-i-n-a-r-p-a-n-e-l-i-s-t-delete.json" -Raw | ConvertFrom-Json
}

Describe 'Remove-ZoomWebinarPanelist' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Returns expected response when removing all panelists' {
            $result = Remove-ZoomWebinarPanelist -WebinarId 123456789 -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Remove-ZoomWebinarPanelist -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs correct URI with webinar ID' {
            Remove-ZoomWebinarPanelist -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match 'https://api\.zoom\.us/v2/webinars/123456789/panelists'
            }
        }

        It 'Uses DELETE method' {
            Remove-ZoomWebinarPanelist -WebinarId 123456789 -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'WebinarId parameter is mandatory' {
            (Get-Command Remove-ZoomWebinarPanelist).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Accepts webinar_id as alias for WebinarId' {
            (Get-Command Remove-ZoomWebinarPanelist).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'Accepts Id as alias for WebinarId' {
            (Get-Command Remove-ZoomWebinarPanelist).Parameters['WebinarId'].Aliases | Should -Contain 'Id'
        }

        It 'WebinarId parameter accepts int64 type' {
            (Get-Command Remove-ZoomWebinarPanelist).Parameters['WebinarId'].ParameterType.Name | Should -Be 'Int64'
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by value' {
            $result = 123456789 | Remove-ZoomWebinarPanelist -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1 -Exactly
        }

        It 'Accepts WebinarId from pipeline by property name' {
            $pipelineInput = [PSCustomObject]@{ WebinarId = 123456789 }
            $result = $pipelineInput | Remove-ZoomWebinarPanelist -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '123456789'
            }
        }

        It 'Accepts Id alias from pipeline by property name' {
            $pipelineInput = [PSCustomObject]@{ Id = 987654321 }
            $result = $pipelineInput | Remove-ZoomWebinarPanelist -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '987654321'
            }
        }

        It 'Processes multiple webinars from pipeline' {
            $webinarIds = @(111111111, 222222222, 333333333)
            $webinarIds | Remove-ZoomWebinarPanelist -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 3 -Exactly
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports -WhatIf parameter' {
            (Get-Command Remove-ZoomWebinarPanelist).Parameters.ContainsKey('WhatIf') | Should -Be $true
        }

        It 'Supports -Confirm parameter' {
            (Get-Command Remove-ZoomWebinarPanelist).Parameters.ContainsKey('Confirm') | Should -Be $true
        }

        It 'Does not call API when -WhatIf is specified' {
            Remove-ZoomWebinarPanelist -WebinarId 123456789 -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0 -Exactly
        }

        It 'Has High ConfirmImpact' {
            $cmdletBinding = (Get-Command Remove-ZoomWebinarPanelist).ScriptBlock.Attributes | 
                Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Error Handling' {
        It 'Throws when API returns error' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error: Webinar not found' }
            { Remove-ZoomWebinarPanelist -WebinarId 999999999 -Confirm:$false } | Should -Throw
        }

        It 'Throws when WebinarId is not provided' {
            { Remove-ZoomWebinarPanelist -Confirm:$false } | Should -Throw
        }
    }
}
