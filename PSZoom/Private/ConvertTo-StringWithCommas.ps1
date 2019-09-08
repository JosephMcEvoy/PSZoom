<#
.DESCRIPTION
Turns @(1,2,3,4) to '1,2,3,4'. 
Sometimes Zoom expects comma separated items in a string, as opposed to an array.
#>

function ConvertTo-StringWithCommas([array]$Array) {
    $Output = ''
    
    $Array | ForEach-Object {
        $Output += "$_,"
    }

    Write-Output $Output.Substring(0, $Output.Length - 1)
}