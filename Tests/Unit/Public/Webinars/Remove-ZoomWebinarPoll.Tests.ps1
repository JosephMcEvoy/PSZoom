BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:PSZoomToken = 'mock-token'
    $script:ZoomURI = 'https://api.zoom.us/v2'
    
    $fixturePath = "$PSScriptRoot/../../../Fixtures/MockResponses/w-e-b-i-n-a-r-p-o-l-l-delete.json"
    if (Test-Path $fixturePath) {
        $script:mockResponse = Get-Content -Path $fixturePath -Raw | ConvertFrom-Json
    } else {
        $script:mockResponse = $null
    }
}

Describe 'Remove-ZoomWebinarPoll' {
    BeforeAll {
        Mock -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
            return $script:mockResponse
        }
    }

    Context 'Basic Functionality' {
        It 'Should execute without error' {
            { Remove-ZoomWebinarPoll -WebinarId '123456789' -PollId 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Should call Invoke-ZoomRestMethod' {
            Remove-ZoomWebinarPoll -WebinarId '123456789' -PollId 'def456' -Confirm:$false
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should return response from API' {
            $result = Remove-ZoomWebinarPoll -WebinarId '123456789' -PollId 'ghi789' -Confirm:$false
            # DELETE endpoints typically return null or empty response
            # The test validates the call completes successfully
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom
        }
    }

    Context 'API Endpoint Construction' {
        It 'Should call correct endpoint with webinar ID and poll ID' {
            Remove-ZoomWebinarPoll -WebinarId '123456789' -PollId 'poll123' -Confirm:$false
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/123456789/polls/poll123'
            }
        }

        It 'Should use DELETE method' {
            Remove-ZoomWebinarPoll -WebinarId '987654321' -PollId 'pollXYZ' -Confirm:$false
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }

        It 'Should handle webinar IDs with different formats' {
            Remove-ZoomWebinarPoll -WebinarId '111222333444' -PollId 'testpoll' -Confirm:$false
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/111222333444/polls/testpoll'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Should require WebinarId parameter' {
            (Get-Command Remove-ZoomWebinarPoll).Parameters['WebinarId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Should require PollId parameter' {
            (Get-Command Remove-ZoomWebinarPoll).Parameters['PollId'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Should have webinar_id alias for WebinarId' {
            (Get-Command Remove-ZoomWebinarPoll).Parameters['WebinarId'].Aliases | Should -Contain 'webinar_id'
        }

        It 'Should have poll_id alias for PollId' {
            (Get-Command Remove-ZoomWebinarPoll).Parameters['PollId'].Aliases | Should -Contain 'poll_id'
        }

        It 'Should accept WebinarId from pipeline by property name' {
            $param = (Get-Command Remove-ZoomWebinarPoll).Parameters['WebinarId']
            $param.Attributes.ValueFromPipelineByPropertyName | Should -Contain $true
        }

        It 'Should accept PollId from pipeline by property name' {
            $param = (Get-Command Remove-ZoomWebinarPoll).Parameters['PollId']
            $param.Attributes.ValueFromPipelineByPropertyName | Should -Contain $true
        }
    }

    Context 'Pipeline Support' {
        It 'Should accept input from pipeline' {
            $pipelineInput = [PSCustomObject]@{
                WebinarId = '555666777'
                PollId = 'pipelinepoll'
            }
            { $pipelineInput | Remove-ZoomWebinarPoll -Confirm:$false } | Should -Not -Throw
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -match '/webinars/555666777/polls/pipelinepoll'
            }
        }

        It 'Should accept multiple objects from pipeline' {
            $pipelineInput = @(
                [PSCustomObject]@{ WebinarId = '111'; PollId = 'poll1' }
                [PSCustomObject]@{ WebinarId = '222'; PollId = 'poll2' }
            )
            { $pipelineInput | Remove-ZoomWebinarPoll -Confirm:$false } | Should -Not -Throw
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }

        It 'Should accept alias property names from pipeline' {
            $pipelineInput = [PSCustomObject]@{
                webinar_id = '888999000'
                poll_id = 'aliaspoll'
            }
            { $pipelineInput | Remove-ZoomWebinarPoll -Confirm:$false } | Should -Not -Throw
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom
        }
    }

    Context 'ShouldProcess Support' {
        It 'Should support WhatIf' {
            Remove-ZoomWebinarPoll -WebinarId '123456789' -PollId 'whatifpoll' -WhatIf
            Should -Invoke -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Should have ConfirmImpact of High' {
            $cmdlet = Get-Command Remove-ZoomWebinarPoll
            $cmdletBinding = $cmdlet.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.ConfirmImpact | Should -Be 'High'
        }

        It 'Should support SupportsShouldProcess' {
            $cmdlet = Get-Command Remove-ZoomWebinarPoll
            $cmdletBinding = $cmdlet.ScriptBlock.Attributes | Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $cmdletBinding.SupportsShouldProcess | Should -Be $true
        }
    }

    Context 'Error Handling' {
        It 'Should handle API errors gracefully' {
            Mock -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'API Error: Poll not found'
            }
            { Remove-ZoomWebinarPoll -WebinarId '123456789' -PollId 'nonexistent' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }

        It 'Should handle network errors' {
            Mock -CommandName Invoke-ZoomRestMethod -ModuleName PSZoom -MockWith {
                throw 'Network connection error'
            }
            { Remove-ZoomWebinarPoll -WebinarId '123456789' -PollId 'test' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
