BeforeAll {
    Import-Module "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1" -Force
    $script:ZoomURI = 'zoom.us'
    $script:PSZoomToken = 'mock-token'
    $script:MockResponse = Get-Content "$PSScriptRoot/../../../Fixtures/MockResponses/phone-outbound-caller-id-customized-number-delete.json" -Raw | ConvertFrom-Json
}

Describe 'Remove-ZoomPhoneOutboundCallerIdCustomizedNumber' {
    BeforeAll {
        Mock Invoke-ZoomRestMethod -ModuleName PSZoom { return $script:MockResponse }
    }

    Context 'Basic Functionality' {
        It 'Executes successfully with single CustomizeId' {
            $result = Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Executes successfully with multiple CustomizeIds' {
            $result = Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds @('abc123', 'def456', 'ghi789') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Returns CustomizeIds when Passthru is specified' {
            $ids = @('abc123', 'def456')
            $result = Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds $ids -Passthru -Confirm:$false
            $result | Should -Be $ids
        }
    }

    Context 'API Endpoint Construction' {
        It 'Calls correct endpoint with single ID' {
            Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds 'abc123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*phone/outbound_caller_id/customized_numbers*' -and
                $Uri -like '*customize_ids=abc123*' -and
                $Method -eq 'DELETE'
            }
        }

        It 'Calls correct endpoint with multiple IDs' {
            Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds @('id1', 'id2', 'id3') -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Uri -like '*phone/outbound_caller_id/customized_numbers*' -and
                $Uri -like '*customize_ids=id1*' -and
                $Uri -like '*customize_ids=id2*' -and
                $Uri -like '*customize_ids=id3*' -and
                $Method -eq 'DELETE'
            }
        }

        It 'Uses DELETE method' {
            Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds 'test123' -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -ParameterFilter {
                $Method -eq 'DELETE'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Accepts CustomizeIds parameter' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts customize_ids alias' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -customize_ids 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts CustomizationIds alias' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizationIds 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts Ids alias' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -Ids 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts Id alias' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -Id 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts positional parameter' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber 'abc123' -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts array of IDs' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds @('id1', 'id2') -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts pipeline input' {
            { 'abc123' | Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -Confirm:$false } | Should -Not -Throw
        }

        It 'Accepts multiple values from pipeline' {
            { @('id1', 'id2', 'id3') | Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -Confirm:$false } | Should -Not -Throw
        }

        It 'Processes each pipeline value' {
            @('id1', 'id2') | Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -Confirm:$false
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 2
        }
    }

    Context 'ShouldProcess Support' {
        It 'Supports WhatIf parameter' {
            $result = Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds 'abc123' -WhatIf
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 0
        }

        It 'Supports Confirm parameter' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds 'abc123' -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Error Handling' {
        BeforeAll {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom { throw 'API Error' }
        }

        It 'Throws error when API call fails' {
            { Remove-ZoomPhoneOutboundCallerIdCustomizedNumber -CustomizeIds 'abc123' -Confirm:$false -ErrorAction Stop } | Should -Throw
        }
    }
}
