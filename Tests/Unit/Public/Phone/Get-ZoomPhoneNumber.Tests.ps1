BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force

    InModuleScope PSZoom {
        $script:PSZoomToken = ConvertTo-SecureString 'test-token' -AsPlainText -Force
        $script:ZoomURI = 'zoom.us'
    }
}

Describe 'Get-ZoomPhoneNumber' {
    Context 'When retrieving all phone numbers' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = '+12345678901'
                        number = '+1 234 567 8901'
                        location = 'New York'
                        type = 'assigned'
                    }
                    @{
                        id = '+19876543210'
                        number = '+1 987 654 3210'
                        location = 'California'
                        type = 'unassigned'
                    }
                )
            }
        }

        It 'Should return phone numbers' {
            $result = Get-ZoomPhoneNumber
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return multiple phone numbers' {
            $result = Get-ZoomPhoneNumber
            $result.Count | Should -Be 2
        }

        It 'Should use correct base URI' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($URI)
                $URI | Should -Match 'https://api.zoom.us/v2/phone/numbers'
                return @()
            }

            Get-ZoomPhoneNumber
            Should -Invoke Get-ZoomPaginatedData -ModuleName PSZoom -Times 1
        }
    }

    Context 'When retrieving specific phone numbers by ID' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{
                        id = '+12345678901'
                        number = '+1 234 567 8901'
                    }
                )
            }
        }

        It 'Should accept PhoneNumberId parameter' {
            $result = Get-ZoomPhoneNumber -PhoneNumberId '+12345678901'
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should pass ObjectId to Get-ZoomPaginatedData' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId | Should -Be '+12345678901'
                return @()
            }

            Get-ZoomPhoneNumber -PhoneNumberId '+12345678901'
        }

        It 'Should accept multiple PhoneNumberIds' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($ObjectId)
                $ObjectId.Count | Should -Be 2
                return @()
            }

            Get-ZoomPhoneNumber -PhoneNumberId '+12345678901', '+19876543210'
        }
    }

    Context 'When using pagination parameters' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept PageSize parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($PageSize)
                $PageSize | Should -Be 50
                return @()
            }

            Get-ZoomPhoneNumber -PageSize 50
        }

        It 'Should accept NextPageToken parameter' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($NextPageToken)
                $NextPageToken | Should -Be 'test-token-123'
                return @()
            }

            Get-ZoomPhoneNumber -NextPageToken 'test-token-123'
        }

        It 'Should validate PageSize range' {
            { Get-ZoomPhoneNumber -PageSize 150 -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'When filtering phone numbers' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should filter by Assigned type' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['type'] | Should -Be 'assigned'
                return @()
            }

            Get-ZoomPhoneNumber -Filter 'Assigned'
        }

        It 'Should filter by Unassigned type' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['type'] | Should -Be 'unassigned'
                return @()
            }

            Get-ZoomPhoneNumber -Filter 'Unassigned'
        }

        It 'Should filter by BYOC type' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['type'] | Should -Be 'byoc'
                return @()
            }

            Get-ZoomPhoneNumber -Filter 'BYOC'
        }

        It 'Should use All filter by default' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                param($AdditionalQueryStatements)
                $AdditionalQueryStatements['type'] | Should -Be 'all'
                return @()
            }

            Get-ZoomPhoneNumber
        }
    }

    Context 'When requesting full details' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @(
                    @{ id = '+12345678901' }
                    @{ id = '+19876543210' }
                )
            }

            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                return @(
                    @{ id = '+12345678901'; details = 'full' }
                    @{ id = '+19876543210'; details = 'full' }
                )
            }
        }

        It 'Should call Get-ZoomItemFullDetails when Full is specified' {
            $result = Get-ZoomPhoneNumber -Full
            Should -Invoke Get-ZoomItemFullDetails -ModuleName PSZoom -Times 1
        }

        It 'Should pass correct CmdletToRun parameter' {
            Mock Get-ZoomItemFullDetails -ModuleName PSZoom {
                param($CmdletToRun)
                $CmdletToRun | Should -Be 'Get-ZoomPhoneNumber'
                return @()
            }

            Get-ZoomPhoneNumber -Full
        }
    }

    Context 'Pipeline support' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept PhoneNumberId from pipeline' {
            { '+12345678901' | Get-ZoomPhoneNumber } | Should -Not -Throw
        }

        It 'Should accept object with id property from pipeline' {
            $phoneObject = [PSCustomObject]@{ id = '+12345678901' }
            { $phoneObject | Get-ZoomPhoneNumber } | Should -Not -Throw
        }

        It 'Should accept object with phone_numbers_Id property from pipeline' {
            $phoneObject = [PSCustomObject]@{ phone_numbers_Id = '+12345678901' }
            { $phoneObject | Get-ZoomPhoneNumber } | Should -Not -Throw
        }
    }

    Context 'Parameter aliases' {
        BeforeEach {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                return @()
            }
        }

        It 'Should accept id alias for PhoneNumberId' {
            { Get-ZoomPhoneNumber -id '+12345678901' } | Should -Not -Throw
        }

        It 'Should accept phone_numbers_Id alias for PhoneNumberId' {
            { Get-ZoomPhoneNumber -phone_numbers_Id '+12345678901' } | Should -Not -Throw
        }

        It 'Should accept page_size alias for PageSize' {
            { Get-ZoomPhoneNumber -page_size 50 } | Should -Not -Throw
        }

        It 'Should accept next_page_token alias for NextPageToken' {
            { Get-ZoomPhoneNumber -next_page_token 'token123' } | Should -Not -Throw
        }
    }

    Context 'Cmdlet aliases' {
        It 'Should be accessible via Get-ZoomPhoneNumbers alias' {
            $alias = Get-Alias -Name 'Get-ZoomPhoneNumbers' -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
            $alias.ResolvedCommandName | Should -Be 'Get-ZoomPhoneNumber'
        }
    }

    Context 'Error handling' {
        It 'Should propagate API errors' {
            Mock Get-ZoomPaginatedData -ModuleName PSZoom {
                throw [System.Net.WebException]::new('Phone number not found')
            }

            { Get-ZoomPhoneNumber -PhoneNumberId '+12345678901' -ErrorAction Stop } | Should -Throw
        }
    }
}
