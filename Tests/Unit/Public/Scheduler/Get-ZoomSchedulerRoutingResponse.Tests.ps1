BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomSchedulerRoutingResponse' {
    Context 'When retrieving a routing form response' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    form_id = 'form123'
                    response_id = 'response789'
                    submitted_at = '2024-01-15T10:00:00Z'
                    responses = @()
                }
            }
        }

        It 'Should return routing response details' {
            $result = Get-ZoomSchedulerRoutingResponse -FormId 'form123' -ResponseId 'response789'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return response with correct form_id' {
            $result = Get-ZoomSchedulerRoutingResponse -FormId 'form123' -ResponseId 'response789'
            $result.form_id | Should -Be 'form123'
        }

        It 'Should return response with correct response_id' {
            $result = Get-ZoomSchedulerRoutingResponse -FormId 'form123' -ResponseId 'response789'
            $result.response_id | Should -Be 'response789'
        }
    }

    Context 'API endpoint construction' {
        It 'Should call API with correct routing response endpoint' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Uri)
                $Uri.ToString() | Should -Match '/v2/scheduler/routing/forms/form123/response/response789'
                return @{}
            }

            Get-ZoomSchedulerRoutingResponse -FormId 'form123' -ResponseId 'response789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }

        It 'Should use GET method' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                param($Method)
                $Method | Should -Be 'GET'
                return @{}
            }

            Get-ZoomSchedulerRoutingResponse -FormId 'form123' -ResponseId 'response789'
            Should -Invoke Invoke-ZoomRestMethod -ModuleName PSZoom -Times 1
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{
                    form_id = 'form123'
                    response_id = 'response789'
                }
            }
        }

        It 'Should accept FormId from pipeline' {
            $result = 'form123' | Get-ZoomSchedulerRoutingResponse -ResponseId 'response789'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should accept object with form_id and response_id properties from pipeline' {
            $routingObject = [PSCustomObject]@{
                form_id = 'form123'
                response_id = 'response789'
            }
            $result = $routingObject | Get-ZoomSchedulerRoutingResponse
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept form_id alias for FormId' {
            { Get-ZoomSchedulerRoutingResponse -form_id 'form123' -ResponseId 'response789' } | Should -Not -Throw
        }

        It 'Should accept response_id alias for ResponseId' {
            { Get-ZoomSchedulerRoutingResponse -FormId 'form123' -response_id 'response789' } | Should -Not -Throw
        }
    }

    Context 'Positional parameters' {
        BeforeEach {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                return @{}
            }
        }

        It 'Should accept FormId and ResponseId as positional parameters' {
            $result = Get-ZoomSchedulerRoutingResponse 'form123' 'response789'
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Invoke-ZoomRestMethod -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Routing response not found')
            }

            { Get-ZoomSchedulerRoutingResponse -FormId 'nonexistent' -ResponseId 'invalid' -ErrorAction Stop } | Should -Throw
        }
    }
}
