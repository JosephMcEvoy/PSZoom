BeforeAll {
    $ModulePath = "$PSScriptRoot/../../../PSZoom/PSZoom.psd1"
    Import-Module $ModulePath -Force
}

Describe 'Get-DateRanges' {
    Context 'When generating date ranges within a single month' {
        It 'Should return single month range' {
            $from = [datetime]'2024-01-01'
            $to = [datetime]'2024-01-15'
            $result = Get-DateRanges -From $from -To $to

            $result.Count | Should -Be 1
            $result['012024'].begin | Should -Be '2024-01-01'
            $result['012024'].end | Should -Be '2024-01-15'
        }

        It 'Should handle full month range' {
            $from = [datetime]'2024-03-01'
            $to = [datetime]'2024-03-31'
            $result = Get-DateRanges -From $from -To $to

            $result['032024'].begin | Should -Be '2024-03-01'
            $result['032024'].end | Should -Be '2024-03-31'
        }
    }

    Context 'When generating date ranges across multiple months' {
        It 'Should return multiple month ranges' {
            $from = [datetime]'2024-01-15'
            $to = [datetime]'2024-03-10'
            $result = Get-DateRanges -From $from -To $to

            $result.Count | Should -Be 3
        }

        It 'Should set correct begin dates for each month' {
            $from = [datetime]'2024-01-15'
            $to = [datetime]'2024-03-10'
            $result = Get-DateRanges -From $from -To $to

            $result['012024'].begin | Should -Be '2024-01-15'
            $result['022024'].begin | Should -Be '2024-02-15'
            $result['032024'].begin | Should -Be '2024-03-15'
        }

        It 'Should set correct end dates respecting month boundaries' {
            $from = [datetime]'2024-01-01'
            $to = [datetime]'2024-03-15'
            $result = Get-DateRanges -From $from -To $to

            $result['012024'].end | Should -Be '2024-01-31'
            $result['022024'].end | Should -Be '2024-02-29' # 2024 is leap year
            $result['032024'].end | Should -Be '2024-03-15'
        }
    }

    Context 'When using custom date format' {
        It 'Should format dates according to Format parameter' {
            $from = [datetime]'2024-06-01'
            $to = [datetime]'2024-06-30'
            $result = Get-DateRanges -From $from -To $to -Format 'MM/dd/yyyy'

            $result['062024'].begin | Should -Be '06/01/2024'
            $result['062024'].end | Should -Be '06/30/2024'
        }
    }

    Context 'Pipeline support' {
        It 'Should accept From date from pipeline' {
            $from = [datetime]'2024-05-01'
            $result = $from | Get-DateRanges -To ([datetime]'2024-05-31')

            $result.Count | Should -Be 1
        }
    }

    Context 'Return type' {
        It 'Should return an ordered hashtable' {
            $from = [datetime]'2024-01-01'
            $to = [datetime]'2024-02-28'
            $result = Get-DateRanges -From $from -To $to

            $result | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
        }
    }
}
