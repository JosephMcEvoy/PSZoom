BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Get-YtdMonthlyDateRanges' {
    Context 'When generating year-to-date ranges with default date' {
        It 'Should return date ranges' {
            InModuleScope PSZoom {
                $result = Get-YtdMonthlyDateRanges
                $result | Should -Not -BeNullOrEmpty
            }
        }

        It 'Should return an ordered hashtable' {
            InModuleScope PSZoom {
                $result = Get-YtdMonthlyDateRanges
                $result | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            }
        }

        It 'Should start from January of current year' {
            InModuleScope PSZoom {
                $result = Get-YtdMonthlyDateRanges
                $firstKey = $result.Keys | Select-Object -First 1
                $currentYear = (Get-Date).Year
                $result[$firstKey].begin | Should -BeLike "$currentYear-01-*"
            }
        }

        It 'Should have begin and end keys for each range' {
            InModuleScope PSZoom {
                $result = Get-YtdMonthlyDateRanges
                foreach ($key in $result.Keys) {
                    $result[$key].Keys | Should -Contain 'begin'
                    $result[$key].Keys | Should -Contain 'end'
                }
            }
        }
    }

    Context 'When using specific date parameter' {
        It 'Should generate ranges from January 1st of specified year' {
            InModuleScope PSZoom {
                $testDate = [datetime]'2023-06-15'
                $result = Get-YtdMonthlyDateRanges -Date $testDate

                $firstKey = $result.Keys | Select-Object -First 1
                $result[$firstKey].begin | Should -Be '2023-01-01'
            }
        }

        It 'Should end at the specified date' {
            InModuleScope PSZoom {
                $testDate = [datetime]'2023-06-15'
                $result = Get-YtdMonthlyDateRanges -Date $testDate

                $lastKey = $result.Keys | Select-Object -Last 1
                $result[$lastKey].end | Should -Be '2023-06-15'
            }
        }

        It 'Should return correct number of months for mid-year date' {
            InModuleScope PSZoom {
                $testDate = [datetime]'2023-06-15'
                $result = Get-YtdMonthlyDateRanges -Date $testDate

                $result.Count | Should -Be 6
            }
        }

        It 'Should return 12 months for end of year date' {
            InModuleScope PSZoom {
                $testDate = [datetime]'2023-12-31'
                $result = Get-YtdMonthlyDateRanges -Date $testDate

                $result.Count | Should -Be 12
            }
        }

        It 'Should return 1 month for January date' {
            InModuleScope PSZoom {
                $testDate = [datetime]'2023-01-15'
                $result = Get-YtdMonthlyDateRanges -Date $testDate

                $result.Count | Should -Be 1
            }
        }
    }

    Context 'Date format' {
        It 'Should use yyyy-MM-dd format by default' {
            InModuleScope PSZoom {
                $result = Get-YtdMonthlyDateRanges
                $firstKey = $result.Keys | Select-Object -First 1
                $result[$firstKey].begin | Should -Match '^\d{4}-\d{2}-\d{2}$'
            }
        }
    }
}
