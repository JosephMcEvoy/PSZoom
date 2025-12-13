BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force

    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'zoom.us'

    $fixturePath = "$PSScriptRoot/../../../Fixtures/MockResponses/webinar-status-put.json"
    if (Test-Path $fixturePath) {
        $script:mockResponse = Get-Content -Path $fixturePath -Raw | ConvertFrom-Json
    } else {
        $script:mockResponse = @{}
    }
}

Describe 'Set-ZoomWebinarStatus' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $script:mockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Returns data when called with required parameters' {
            $result = Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'end' -Confirm:$false
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Calls Invoke-ZoomRestMethod exactly once' {
            Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'end' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Exactly 1
        }
    }

    Context 'API Endpoint Construction' {
        It 'Constructs the correct API endpoint URL' {
            Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'end' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*zoom.us/v2/webinars/123456789/status*'
            }
        }

        It 'Uses PUT method' {
            Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'end' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'PUT'
            }
        }

        It 'Includes action in request body' {
            Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'end' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Body -like '*action*' -and $Body -like '*end*'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Requires WebinarId parameter' {
            (Get-Command Set-ZoomWebinarStatus).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Accepts webinar_id as alias for WebinarId' {
            $param = (Get-Command Set-ZoomWebinarStatus).Parameters['WebinarId']
            $param.Aliases | Should -Contain 'webinar_id'
        }

        It 'Accepts Id as alias for WebinarId' {
            $param = (Get-Command Set-ZoomWebinarStatus).Parameters['WebinarId']
            $param.Aliases | Should -Contain 'Id'
        }

        It 'Validates Action parameter values' {
            $param = (Get-Command Set-ZoomWebinarStatus).Parameters['Action']
            $validateSet = $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateSetAttribute] }
            $validateSet.ValidValues | Should -Contain 'end'
        }

        It 'Rejects invalid Action values' {
            { Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'invalid' -Confirm:$false } | Should -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts WebinarId from pipeline by property name' {
            $param = (Get-Command Set-ZoomWebinarStatus).Parameters['WebinarId']
            $param.Attributes.ValueFromPipelineByPropertyName | Should -Contain $true
        }

        It 'Accepts WebinarId from pipeline by value' {
            $param = (Get-Command Set-ZoomWebinarStatus).Parameters['WebinarId']
            $param.Attributes.ValueFromPipeline | Should -Contain $true
        }

        It 'Processes pipeline input correctly' {
            $pipelineInput = [PSCustomObject]@{ WebinarId = 123456789 }
            $result = $pipelineInput | Set-ZoomWebinarStatus -Action 'end' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*webinars/123456789/status*'
            }
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            $result = Set-ZoomWebinarStatus -WebinarId 123456789 -Action 'end' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Exactly 0
        }

        It 'Has ConfirmImpact set to High' {
            $cmdletAttribute = (Get-Command Set-ZoomWebinarStatus).ScriptBlock.Attributes | 
                Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletAttribute.ConfirmImpact | Should -Be 'High'
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Webinar not found'
            }
        }

        It 'Propagates API errors correctly' {
            { Set-ZoomWebinarStatus -WebinarId 999999999 -Action 'end' -Confirm:$false } | Should -Throw '*API Error*'
        }
    }
}
