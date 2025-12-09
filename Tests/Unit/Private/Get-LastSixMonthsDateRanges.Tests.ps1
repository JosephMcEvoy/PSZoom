BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Get-LastSixMonthsDateRanges' {
    Context 'When generating last six months date ranges' {
        BeforeAll {
            $result = Get-LastSixMonthsDateRanges
        }

        It 'Should return date ranges' {
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Should return an ordered hashtable' {
            $result | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
        }

        It 'Should return approximately 6-7 months of ranges' {
            # Could be 6 or 7 depending on day of month
            $result.Count | Should -BeGreaterOrEqual 6
            $result.Count | Should -BeLessOrEqual 7
        }

        It 'Should have begin and end keys for each range' {
            foreach ($key in $result.Keys) {
                $result[$key].Keys | Should -Contain 'begin'
                $result[$key].Keys | Should -Contain 'end'
            }
        }

        It 'Should use yyyy-MM-dd format by default' {
            $firstKey = $result.Keys | Select-Object -First 1
            $result[$firstKey].begin | Should -Match '^\d{4}-\d{2}-\d{2}$'
        }
    }

    Context 'Date boundary validation' {
        It 'Should start approximately 6 months ago' {
            $result = Get-LastSixMonthsDateRanges
            $firstKey = $result.Keys | Select-Object -First 1
            $beginDate = [datetime]$result[$firstKey].begin

            $sixMonthsAgo = (Get-Date).AddMonths(-6)
            $daysDifference = [math]::Abs(($beginDate - $sixMonthsAgo).Days)

            # Allow for 5 day variance due to the +2 days adjustment in the function
            $daysDifference | Should -BeLessOrEqual 5
        }

        It 'Should end at current date' {
            $result = Get-LastSixMonthsDateRanges
            $lastKey = $result.Keys | Select-Object -Last 1
            $endDate = [datetime]$result[$lastKey].end

            $today = Get-Date
            $daysDifference = [math]::Abs(($endDate - $today).Days)

            $daysDifference | Should -BeLessOrEqual 1
        }
    }
}
