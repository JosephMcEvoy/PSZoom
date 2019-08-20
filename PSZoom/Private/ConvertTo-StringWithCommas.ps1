function ConvertTo-StringWithCommas([array]$Array) {
    $Output = ''
    
    $Array | ForEach-Object {
        $Output += "$_,"
    }

    Write-Output $Output.Substring(0, $Output.Length - 1)
}